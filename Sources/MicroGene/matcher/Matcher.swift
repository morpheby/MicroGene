//
//  Matcher.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation

public class Matcher: Matching {

    public struct BindingInformation {
        var binding: AnyVariableBinding
        var path: Path
    }

    private struct MatchableInformation {
        var type: Matchable.Type
        var onMatch: (Matchable) -> ()
        var partials: [AnyHashable: [BindingInformation]]
    }

    private struct ConcreteBinding {
        var information: Box<MatchableInformation>
        var binding: AnyVariableBinding
    }

    private var allMatchables: [ObjectIdentifier: Box<MatchableInformation>]
    private var compiledExpressions: PathMatchingTree<ConcreteBinding> {
        if let c = _compiledExpressions { return c }
        else { compileExpressions() ; return _compiledExpressions! }
    }
    private var _compiledExpressions: PathMatchingTree<ConcreteBinding>?

    public init() {
        allMatchables = [:]
        _compiledExpressions = PathMatchingTree()
    }

    /// Check if a new value `value` at `path` can match any of the registered `Matchable`a.
    /// If it can, it returns `true`, and the value is already taken (you shouldn't save it into storage then).
    /// It it can't, it returns `false` and you should store the value to the storage.
    public func match(value: AnyStorable, at path: Path, storage: Storing) -> Bool {
        let candidateList = compiledExpressions.allExpressions(satisfying: path).lazy
            .filter { c in c.binding.isCompatible(with: type(of: value)) }
            .sorted { (lhv, rhv) -> Bool in
                if lhv.information.boxed.type.priority == rhv.information.boxed.type.priority {
                    return lhv.information.boxed.type.bindings.count > rhv.information.boxed.type.bindings.count
                } else {
                    return lhv.information.boxed.type.priority > rhv.information.boxed.type.priority
                }
            }

        let boxedValue = Box(value)

        for concreteBinding in candidateList {
            var partials = concreteBinding.information.boxed.partials[concreteBinding.binding.anyHashable] ?? []

            // Yeah, that seems like a terrible solution, but it is the only way in MicroGene — GeSA will have full expressions and
            // affectively such crude method won't be required anymore. MicroGene — is for micro tasks, not huge projects :)
            let newBinding = BindingInformation(binding: concreteBinding.binding, path: path)

            // First, collect other vars
            let otherVars = concreteBinding.information.boxed.partials.filter { key, _ in key != concreteBinding.binding.anyHashable }

            // Proceed only if all variables have been set
            if Set(otherVars.keys + [concreteBinding.binding.anyHashable]) == Set(concreteBinding.information.boxed.type.bindings.map { b in b.anyHashable }) {

                // For cleanup, collect dead paths
                var deadPaths: [AnyHashable: [Path]] = [:]

                // Collect all combinations
                var possibleMatches: [[(BindingInformation, Box<AnyStorable>)]] = [[]]
                var takenVars: [Path: [Box<AnyStorable>]] = [:]
                for (_, bindings) in otherVars {
                    // Compute cartesian product
                    var new: [[(BindingInformation, Box<AnyStorable>)]] = []
                    let bindVars: [(BindingInformation, Box<AnyStorable>)] =
                        bindings.flatMap { (b: BindingInformation) -> [(BindingInformation, Box<AnyStorable>)] in
                            // Take everything
                            let t: [AnyStorable] = storage.takeAll(from: b.path)
                            if t.count == 0 {
                                if deadPaths[b.binding.anyHashable] == nil { deadPaths[b.binding.anyHashable] = [] }
                                deadPaths[b.binding.anyHashable]?.append(b.path)
                            }
                            // Leave out only those that are of a usable type to use
                            let tTake = t.filter { v in b.binding.isCompatible(with: type(of: v)) } .map { v in Box(v) }
                            let tReturn = t.filter { v in !b.binding.isCompatible(with: type(of: v)) }

                            takenVars[b.path] = tTake
                            storage.put(values: tReturn, to: b.path)
                            return tTake.map {(x: Box<AnyStorable>) -> (BindingInformation,Box<AnyStorable>) in
                                return (b,x)
                            }
                        }
                    for b in bindVars {
                        for a in possibleMatches {
                            new.append(a + [b])
                        }
                    }
                    possibleMatches = new.map { a in a + [(newBinding, boxedValue)] }
                }

                // Cleanup dead paths
                for (hashable, paths) in deadPaths {
                    for path in paths {
                        if let idx = (concreteBinding.information.boxed.partials[hashable]?.index { v in v.path == path }) {
                            concreteBinding.information.boxed.partials[hashable]?.remove(at: idx)
                        } else {
                            fatalError("Binding appeared out of nowhere...")
                        }
                    }
                }


                // Check every combination till something is found
                for vars in possibleMatches {
                    var potential: Matchable = concreteBinding.information.boxed.type.init()
                    for (bindingInfo, value) in vars {
                        bindingInfo.binding.write(value.boxed, for: bindingInfo.path, to: &potential)
                    }
                    if potential.match() {
                        // Put everything back
                        let t = takenVars.map { path, values in
                            (path, values.filter { b in
                                !vars.reduce(false) { x, v in let (_,v) = v ; return x || v === b }
                            })
                        }

                        for (path, values) in t {
                            storage.put(values: values.map { v in v.boxed }, to: path)
                        }
                        concreteBinding.information.boxed.onMatch(potential)
                        return true
                    }
                }

                // So this one didn't work out, return all vars
                for (path, values) in takenVars {
                    storage.put(values: values.map { v in v.boxed }, to: path)
                }
            }

            // If we are here, we found nothing. Store the binding, if it's not already present
            if (partials.filter { p in p.path == path}).isEmpty {
                partials.append(newBinding)
            }

            concreteBinding.information.boxed.partials[concreteBinding.binding.anyHashable] = partials
        }
        
        return false
    }

    private func compileExpressions() {
        let allExpressions: [(PathExpression, ConcreteBinding)] =
            allMatchables.values.lazy.flatMap { m in m.boxed.type.bindings.lazy.map { b in (b.path, ConcreteBinding(information: m, binding: b)) } }
        _compiledExpressions = PathMatchingTree(expressions: allExpressions)
    }

    public func register<T>(_ matchableType: T.Type, onMatch matchClosure: @escaping (T) -> ()) where T: Matchable {
        _compiledExpressions = nil
        let typeErasedClodure = { (m: Matchable) -> () in
            guard let typedM = m as? T else { fatalError("Internal error while restoring type information") }
            matchClosure(typedM)
        }
        allMatchables[ObjectIdentifier(matchableType)] = Box(MatchableInformation(type: matchableType, onMatch: typeErasedClodure, partials: [:]))
    }

}

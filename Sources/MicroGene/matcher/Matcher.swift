//
//  Matcher.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation

public class Matcher: Matching {

    private struct BindingInformation {
        var binding: AnyVariableBinding
        var path: Path
        var value: AnyStorable
    }

    private struct MathableInformation {
        var type: Matchable.Type
        var onMatch: (Matchable) -> ()
        var partials: [AnyHashable: [BindingInformation]]
    }

    private struct ConcreteBinding {
        var information: Box<MathableInformation>
        var binding: AnyVariableBinding
    }

    private var allMatchables: [ObjectIdentifier: Box<MathableInformation>]
    private var compiledExpressions: PathMatchingTree<ConcreteBinding> {
        if let c = _compiledExpressions { return c }
        else { compileExpressions() ; return _compiledExpressions! }
    }
    private var _compiledExpressions: PathMatchingTree<ConcreteBinding>?

    public init() {
        allMatchables = [:]
        _compiledExpressions = PathMatchingTree()
    }

    public func match(value: AnyStorable, at path: Path, removed: Bool) {
        let candidateList = compiledExpressions.allExpressions(satisfying: path).lazy
            .filter { c in c.binding.isCompatible(with: type(of: value)) }
            .sorted { (lhv, rhv) -> Bool in
                if lhv.information.boxed.type.priority == rhv.information.boxed.type.priority {
                    return lhv.information.boxed.type.bindings.count > rhv.information.boxed.type.bindings.count
                } else {
                    return lhv.information.boxed.type.priority > rhv.information.boxed.type.priority
                }
            }

        for concreteBinding in candidateList {
            var partials = concreteBinding.information.boxed.partials[concreteBinding.binding.anyHashable] ?? []

            if removed {
                partials = partials.filter { p in p.path == path }
            } else {
                // Yeah, that seems like a terrible solution, but it is the only way in MicroGene — GeSA will have full expressions and
                // affectively such crude method won't be required anymore. MicroGene — is for micro tasks, not huge projects :)
                let newBinding = BindingInformation(binding: concreteBinding.binding, path: path, value: value)

                // First, collect other vars
                let otherVars = concreteBinding.information.boxed.partials.filter { key, _ in key != concreteBinding.binding.anyHashable }

                // Proceed only if all variables have been set
                if Set(otherVars.keys) == Set(concreteBinding.information.boxed.type.bindings.map { b in b.anyHashable }) {

                    // Collect all combinations
                    var possibleMatches: [[BindingInformation]] = [[]]
                    for (_, bindings) in otherVars {
                        // Compute cartesian product
                        var new: [[BindingInformation]] = []
                        for b in bindings {
                            for a in possibleMatches {
                                new.append(a + [b])
                            }
                        }
                        possibleMatches = new.map { a in a + [newBinding] }
                    }

                    // Check every combination till something is found
                    for vars in possibleMatches {
                        var potential: Matchable = concreteBinding.information.boxed.type.init()
                        for bindingInfo in vars {
                            bindingInfo.binding.write(bindingInfo.value, to: &potential)
                        }
                        if  potential.match() {
                            concreteBinding.information.boxed.onMatch(potential)
                            return
                        }
                    }
                }

                // If we are here, we found nothing. Store the binding
                partials.append(newBinding)
            }

            concreteBinding.information.boxed.partials[concreteBinding.binding.anyHashable] = partials
        }
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
        allMatchables[ObjectIdentifier(matchableType)] = Box(MathableInformation(type: matchableType, onMatch: typeErasedClodure, partials: [:]))
    }

}

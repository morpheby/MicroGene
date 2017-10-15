//
//  CompiledExpressionMatching.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/15/17.
//

import Foundation

struct CompiledExpressionBox<T> {
    var list: [Box<T>]

    init(_ list: [Box<T>]) {
        self.list = list
    }
}

protocol CompiledExpressionMatching {
    associatedtype Match
    associatedtype Result

    func match(_ value: Match) -> [Result]
}

protocol CompiledPartialExpressionMatching {
    associatedtype Match
    associatedtype Result

    func match(_ value: Match) -> [(Match, Result)]
}

struct CompiledCompartmentPartialExpression<T> {
    var node: [CompartmentId: CompiledCompartmentPartialExpression]
    var root: [CompartmentId: CompiledCompartmentExpression<T>]

    var anyRoot: Box<CompiledCompartmentExpression<T>?>
    var anyNode: Box<CompiledCompartmentPartialExpression?>

    fileprivate init() {
        self.node = [:]
        self.root = [:]
        self.anyRoot = Box(nil)
        self.anyNode = Box(nil)
    }
}

struct CompiledCompartmentExpression<T> {
    var node: [CompartmentId: CompiledCompartmentExpression<T>]
    var repeating: CompiledCompartmentPartialExpression<T>
    var staticRepeatingPartials: CompartmentPartialExpression
    var root: CompiledExpressionBox<T>

    var anyNode: Box<CompiledCompartmentExpression<T>?>

    fileprivate init() {
        self.node = [:]
        self.repeating = CompiledCompartmentPartialExpression()
        self.root = CompiledExpressionBox([])
        self.anyNode = Box(nil)
    }
}

struct CompiledPathExpression<T> {
    var storable: [StorableId: CompiledCompartmentExpression<T>]
    var any: Box<CompiledCompartmentExpression<T>?>

    fileprivate init() {
        self.storable = [:]
        self.any = Box(nil)
    }
}

extension CompiledCompartmentPartialExpression: CompiledPartialExpressionMatching {
    typealias Match = CompartmentIndex
    typealias Result = CompiledCompartmentExpression<T>

    func match(_ compartment: CompartmentIndex) -> [(CompartmentIndex, CompiledCompartmentExpression<T>)] {
        var result: [(CompartmentIndex, CompiledCompartmentExpression<T>)] = []
        guard case let .node(otherId, parent) = compartment else { return result }

        result.append(contentsOf: node[otherId]?.match(parent) ?? [])
        result.append(contentsOf: anyNode.boxed?.match(parent) ?? [])

        if let a = anyRoot.boxed {
            result.append((parent, a))
        }
        if let a = root[otherId] {
            result.append((parent, a))
        }

        return result
    }
}

extension CompiledCompartmentExpression: CompiledExpressionMatching {
    typealias Match = CompartmentIndex
    typealias Result = CompiledExpressionBox<T>

    func match(_ compartment: CompartmentIndex) -> [CompiledExpressionBox<T>] {
        var result: [CompiledExpressionBox<T>] = []

        guard case let .node(otherId, parent) = compartment else { return [root] }

        result.append(contentsOf: node[otherId]?.match(parent) ?? [])
        result.append(contentsOf: anyNode.boxed?.match(parent) ?? [])

//        var lastSuccess: CompartmentIndex? = parent
//        while let compartment = lastSuccess {
//            let result = partial.match(compartment)
//            if let r = result {
//                if parent.match(r) {
//                    return true
//                }
//            }
//            lastSuccess = result
//        }

//        var possibleRepeats: [(CompartmentIndex, CompiledCompartmentPartialExpression<T>)] = [(compartment, repeating)]
//        while !possibleRepeats.isEmpty {
//            let (c, r) = possibleRepeats.removeFirst()
//
//            let newRepeats = r.match(c)
//
//            result.append(contentsOf: newRepeats.flatMap { index, parent in parent.match(index) })
//            possibleRepeats.append(contentsOf: newRepeats.map { index, _ in (index, r) })
//        }

        return result
    }
}

extension CompiledPathExpression: CompiledExpressionMatching {
    typealias Match = Path
    typealias Result = CompiledExpressionBox<T>

    func match(_ path: Path) -> [CompiledExpressionBox<T>] {
        var result: [CompiledExpressionBox<T>] = []

        result.append(contentsOf: storable[path.storable]?.match(path.compartment) ?? [])
        result.append(contentsOf: any.boxed?.match(path.compartment) ?? [])

        return result
    }
}

extension CompiledCompartmentExpression {
    fileprivate mutating func _add(compartmentExpression: CompartmentExpression, with value: Box<T>) {
        switch compartmentExpression {
        case let .node(.any, parent: parentExpression):
            if anyNode.boxed == nil { anyNode.boxed = CompiledCompartmentExpression() }
            anyNode.boxed?._add(compartmentExpression: parentExpression, with: value)
        case let .node(.id(id), parent: parentExpression):
            if node[id] == nil { node[id] = CompiledCompartmentExpression() }
            node[id]?._add(compartmentExpression: parentExpression, with: value)
        case let .root(.node(id, parent: parent)):
            if node[id] == nil { node[id] = CompiledCompartmentExpression() }
            node[id]?._add(compartmentExpression: .root(parent), with: value)
        case .root(.root):
            root.list.append(value)
        case let .repeating(expression: partial, parent: parentExpression):
            repeating._add(partialExpression: partial)
            if repeatingParent.boxed == nil { repeatingParent.boxed = CompiledCompartmentExpression() }
            repeatingParent.boxed?._add(compartmentExpression: parentExpression, with: value)
        }
    }
}

extension CompiledCompartmentPartialExpression {
    fileprivate mutating func _add(partialExpression: CompartmentPartialExpression) {
        switch partialExpression {
        case let .node(.any, parentPartial):
            if anyNode.boxed == nil { anyNode.boxed = CompiledCompartmentPartialExpression() }
            anyNode.boxed?._add(partialExpression: parentPartial)
        case let .node(.id(id), parentPartial):
            if node[id] == nil { node[id] = CompiledCompartmentPartialExpression() }
            node[id]?._add(partialExpression: parentPartial)
        case .root(.any):
            anyRoot = true
        case let .root(.id(id)):
            root.insert(id)
        }
    }
}

extension CompiledPathExpression {
    fileprivate mutating func _add(pathExpression: PathExpression, with value: Box<T>) {
        switch pathExpression {
        case let .or(one, two):
            _add(pathExpression: one, with: value)
            _add(pathExpression: two, with: value)
        case let .single(.any, compartmentExpression):
            if any.boxed == nil { any.boxed = CompiledCompartmentExpression() }
            any.boxed?._add(compartmentExpression: compartmentExpression, with: value)
        case let .single(.id(id), compartmentExpression):
            if storable[id] == nil { storable[id] = CompiledCompartmentExpression() }
            storable[id]?._add(compartmentExpression: compartmentExpression, with: value)
        }
    }
}

struct PathMatchingTree<T> {
    var compiledPathExpression: CompiledPathExpression<T>

    init() {
        compiledPathExpression = CompiledPathExpression()
    }

    init(expressions: [(PathExpression, T)]) {
        compiledPathExpression = CompiledPathExpression()
        for (expression, value) in expressions {
            self.add(pathExpression: expression, with: value)
        }
    }

    mutating func add(pathExpression: PathExpression, with value: T) {
        let box = Box(value)
        compiledPathExpression._add(pathExpression: pathExpression, with: box)
    }

    func allExpressions(satisfying path: Path) -> [Box<T>] {
        let compiled = compiledPathExpression.match(path)
        return compiled.flatMap { c in c.list}
    }
}


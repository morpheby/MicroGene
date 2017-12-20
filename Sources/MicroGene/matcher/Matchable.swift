//
//  Matchable.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation

public protocol AnyVariableBinding: AnyHashableConvertible {

    var path: PathExpression { get }

    func isCompatible(with type: AnyStorable.Type) -> Bool

    // TODO: Remove double functions when Swift generics work the way they are supposed to
    func write<T,U>(_ value: CompleteValue<U>, for path: Path, to holder: inout T) where T: Matchable
    func writeUntyped(_ value: AnyCompleteValue, for path: Path, to holder: inout Matchable)
}

public struct Var<Wrapped> where Wrapped: AnyStorable {
    public var value: Wrapped {
        get { return _value }
        set { _value = newValue }
    }

    public var state: StorableState {
        get { return _state }
    }

    public var path: Path {
        get { return _path }
    }

    public init() { }
    public init(_: Wrapped.Type) { }

    fileprivate var _value: Wrapped!
    fileprivate var _state: StorableState!
    fileprivate var _path: Path!
}

private struct VariableBinding<Matcher, Variable>: AnyVariableBinding where Matcher: Matchable, Variable: AnyStorable {
    public var path: PathExpression

    func isCompatible(with type: AnyStorable.Type) -> Bool {
        return typeChecker.accepts(type: type)
    }

    private let typeChecker = TypeChecker(Variable.self)

    public var keyPath: WritableKeyPath<Matcher, Var<Variable>>

    // TODO: Remove double functions when Swift generics work the way they are supposed to
    private func _write(_ value: CompleteValue<Variable>, for path: Path, to holder: inout Matcher) {
        let pathKeyPath: WritableKeyPath<Matcher, ImplicitlyUnwrappedOptional<Path>> = keyPath.appending(path: \Var<Variable>._path)
        let stateKeyPath: WritableKeyPath<Matcher, ImplicitlyUnwrappedOptional<StorableState>> = keyPath.appending(path: \Var<Variable>._state)
        let valueKeyPath: WritableKeyPath<Matcher, ImplicitlyUnwrappedOptional<Variable>> = keyPath.appending(path: \Var<Variable>._value)
        holder[keyPath: pathKeyPath] = path
        holder[keyPath: stateKeyPath] = value.state
        holder[keyPath: valueKeyPath] = value.value
    }

    public func write<T,U>(_ value: CompleteValue<U>, for path: Path, to holder: inout T) where T: Matchable {
        guard var matcher = holder as? Matcher else { preconditionFailure("Invalid holder supplied to VariableBinding") }
        guard let variableValue = value.typed() as CompleteValue<Variable>? else { preconditionFailure("Invalid value supplied to VariableBinding")}

        _write(variableValue, for: path, to: &matcher)

        // In case holder has value-type semantics, copy value
        // (has no effect if it has reference sematics)
        holder = matcher as! T
    }

    public func writeUntyped(_ value: AnyCompleteValue, for path: Path, to holder: inout Matchable) {
        guard var matcher = holder as? Matcher else { preconditionFailure("Invalid holder supplied to VariableBinding") }
        guard let variableValue = value.typed() as CompleteValue<Variable>? else { preconditionFailure("Invalid value supplied to VariableBinding")}

        _write(variableValue, for: path, to: &matcher)

        // In case holder has value-type semantics, copy value
        // (has no effect if it has reference sematics)
        holder = matcher as Matchable
    }
}

public func <> <Matcher, Variable>(lhv: PathExpression, rhv: WritableKeyPath<Matcher, Var<Variable>>) -> AnyVariableBinding where Matcher: Matchable {
    return VariableBinding(path: lhv, keyPath: rhv)
}

extension VariableBinding: Equatable {
    static func == (lhv: VariableBinding<Matcher, Variable>, rhv: VariableBinding<Matcher, Variable>) -> Bool {
        return lhv.keyPath == rhv.keyPath
        // XXX: Maybe also compare path
    }
}

extension VariableBinding: Hashable {
    var hashValue: Int {
        return keyPath.hashValue
    }
}

extension VariableBinding: AnyHashableConvertible {
    public var anyHashable: AnyHashable {
        return AnyHashable(self)
    }
}

public protocol Matchable {
    static var bindings: [AnyVariableBinding] { get }
    static var priority: Priority { get }

    init()

    func match() -> Bool
}


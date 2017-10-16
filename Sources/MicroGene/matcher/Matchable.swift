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
    func write<T,U>(_ value: U, for path: Path, to holder: inout T) where T: Matchable, U: AnyStorable
    func write(_ value: AnyStorable, for path: Path, to holder: inout Matchable)
}

public struct Var<Wrapped> where Wrapped: AnyStorable {
    public var value: Wrapped {
        get {
            return _value
        }
        set {
            _value = newValue
        }
    }

    public var path: Path {
        get {
            return _path
        }
    }

    public init() { }
    public init(_: Wrapped.Type) { }

    fileprivate var _value: Wrapped!
    fileprivate var _path: Path!
}

private struct VariableBinding<Matcher, Variable>: AnyVariableBinding where Matcher: Matchable, Variable: AnyStorable {
    public var path: PathExpression

    func isCompatible(with type: AnyStorable.Type) -> Bool {
        return type.isSelf(convertibleTo: Variable.self)
    }

    public var keyPath: WritableKeyPath<Matcher, Var<Variable>>

    private func _write(_ value: Variable, for path: Path, to holder: inout Matcher) {
        holder[keyPath: keyPath]._path = path
        holder[keyPath: keyPath]._value = value
    }

    public func write<T,U>(_ value: U, for path: Path, to holder: inout T) where T: Matchable, U: AnyStorable {
        guard var matcher = holder as? Matcher else { preconditionFailure("Invalid holder supplied to VariableBinding") }
        guard let variableValue = value as? Variable else { preconditionFailure("Invalid value supplied to VariableBinding")}

        _write(variableValue, for: path, to: &matcher)

        // In case holder has value-type semantics, copy value
        // (has no effect if it has reference sematics)
        holder = matcher as! T
    }

    public func write(_ value: AnyStorable, for path: Path, to holder: inout Matchable) {
        guard var matcher = holder as? Matcher else { preconditionFailure("Invalid holder supplied to VariableBinding") }
        guard let variableValue = value as? Variable else { preconditionFailure("Invalid value supplied to VariableBinding")}

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
    static var priority: Int { get }

    init()

    func match() -> Bool
}


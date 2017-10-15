//
//  Matchable.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation

public protocol AnyVariableBinding {
    var path: PathExpression { get }
    var type: Any.Type { get }
    func write<T,U>(_ value: U, to holder: inout T) where T: Matchable, U: Storable
}

private struct VariableBinding<Matcher, Variable> where Matcher: Matchable, Variable: Storable {
    public var path: PathExpression

    public var type: Any.Type {
        return Variable.self
    }

    public var keyPath: WritableKeyPath<Matcher, ImplicitlyUnwrappedOptional<Variable>>

    public func write<T,U>(_ value: U, to holder: inout T) where T: Matchable, U: Storable {
        guard var matcher = holder as? Matcher else { preconditionFailure("Invalid holder supplied to VariableBinding") }
        guard let variableValue = value as? Variable else { preconditionFailure("Invalid value supplied to VariableBinding")}

        matcher[keyPath: keyPath] = variableValue

        // In case holder has value-type semantics, copy value
        // (has no effect if it has reference sematics)
        holder = matcher as! T
    }
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


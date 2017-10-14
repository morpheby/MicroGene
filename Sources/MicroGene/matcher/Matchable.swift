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

extension AnyVariableBinding {
//    func write<T,U>(_ value: T, to holder: inout U)
}

public struct VariableBinding<Matcher, Variable>: AnyVariableBinding where Matcher: Matchable, Variable: Storable {
    public var path: PathExpression

    public var type: Any.Type {
        return Variable.self
    }

    public var keyPath: WritableKeyPath<Matcher, Variable>

    public func write<T,U>(_ value: U, to holder: inout T) where T: Matchable, U: Storable {
        guard var matcher = holder as? Matcher else { preconditionFailure("Invalid holder supplied to VariableBinding") }
        guard let variableValue = value as? Variable else { preconditionFailure("Invalid value supplied to VariableBinding")}

        matcher[keyPath: keyPath] = variableValue

        // In case holder has value-type semantics, copy value
        // (has no effect if it has reference sematics)
        holder = matcher as! T
    }
}

public protocol Matchable {
    static var bindings: [AnyVariableBinding] { get }

    func match() -> Bool
}


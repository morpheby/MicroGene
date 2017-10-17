//
//  TypeChecker.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/16/17.
//

import Foundation

public protocol TypeChecking {
    func accepts(type: Any.Type) -> Bool
}

public struct TypeChecker<T>: TypeChecking {
    public init(_: T.Type) { }
    public func accepts(type: Any.Type) -> Bool {
        return type as? T.Type != nil
    }
}

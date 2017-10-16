//
//  Value.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/12/17.
//

import Foundation

public protocol AnyStorable {
    static func isSelf(convertibleTo valueType: AnyStorable.Type) -> Bool
}

public protocol Storable: AnyStorable {
    typealias ActualType = Self
}

extension Storable {
    static func isSelf(convertibleTo valueType: AnyStorable.Type) -> Bool {
        return valueType as? ActualType.Type != nil
    }
}


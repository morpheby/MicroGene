//
//  StorableId.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/12/17.
//

import Foundation

public struct StorableId: RawRepresentable {
    public typealias RawValue = String

    public var name: String

    public init(name: String) {
        self.name = name + locallyUniqueId()
    }

    public init?(rawValue: StorableId.RawValue) {
        self.name = rawValue
    }

    public var rawValue: StorableId.RawValue {
        return name
    }
}

extension StorableId: Equatable {
    public static func == (lhv: StorableId, rhv: StorableId) -> Bool {
        guard lhv.name == rhv.name else { return false }

        return true
    }
}

extension StorableId: Hashable {
    public var hashValue: Int {
        return name.hashValue
    }
}

extension StorableId: CustomStringConvertible {
    public var description: String {
        return self.name
    }
}

//
//  CompartmentId.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/20/17.
//

import Foundation

public struct CompartmentId: RawRepresentable {
    public typealias RawValue = String

    public var name: String

    public init(name: String) {
        self.name = name + locallyUniqueId()
    }

    public init?(rawValue: CompartmentId.RawValue) {
        self.name = rawValue
    }

    public var rawValue: CompartmentId.RawValue {
        return name
    }
}

extension CompartmentId: Equatable {
    public static func == (lhv: CompartmentId, rhv: CompartmentId) -> Bool {
        guard lhv.name == rhv.name else { return false }

        return true
    }
}

extension CompartmentId: Hashable {
    public var hashValue: Int {
        return name.hashValue
    }
}

extension CompartmentId: CustomStringConvertible {
    public var description: String {
        return self.name
    }
}

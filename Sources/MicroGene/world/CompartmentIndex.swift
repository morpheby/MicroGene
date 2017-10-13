//
//  CompartmentIndex.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/12/17.
//

import Foundation

public struct CompartmentId: RawRepresentable {
    public typealias RawValue = String

    public var rawValue: String

    public init?(rawValue: CompartmentId.RawValue) {
        self.rawValue = rawValue
    }
}

extension CompartmentId: Hashable {
    public var hashValue: Int {
        return rawValue.hashValue
    }
}

public struct CompartmentIndex {

    public var id: CompartmentId
    private var parentStorage: [CompartmentIndex] = []

    public var parent: CompartmentIndex? {
        get {
            return parentStorage.first
        }
        set {
            parentStorage.removeAll()
            if let v = newValue {
                parentStorage.append(v)
            }
        }
    }

    public init(id: CompartmentId) {
        self.id = id
        self.parent = nil
    }

    public init(id: CompartmentId, parent: CompartmentIndex) {
        self.id = id
        self.parent = parent
    }
}

extension CompartmentIndex: Equatable {
    public static func == (lhv: CompartmentIndex, rhv: CompartmentIndex) -> Bool {
        guard lhv.id == rhv.id else { return false }

        guard lhv.parent == rhv.parent else { return false }

        return true
    }
}

extension CompartmentIndex: Hashable {
    public var hashValue: Int {
        return id.hashValue ^ (parent?.hashValue ?? 0)
    }
}

extension CompartmentId {
    internal static let root = CompartmentId(rawValue: "__root_node")!
}

extension CompartmentIndex {
    internal static let rootCompartment = CompartmentIndex(id: CompartmentId.root)
}

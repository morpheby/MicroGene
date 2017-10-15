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

public enum CompartmentIndex {
    case root
    indirect case node(id: CompartmentId, parent: CompartmentIndex)
}

extension CompartmentIndex: Equatable {
    public static func == (lhv: CompartmentIndex, rhv: CompartmentIndex) -> Bool {
        switch (lhv, rhv) {
        case (.root, .root):
            return true
        case let (.node(lid, lparent), .node(rid, rparent)):
            return lid == rid && lparent == rparent
        default:
            return false
        }
    }
}

fileprivate let MAGIC_ROOT_VALUE = 9992888331

extension CompartmentIndex: Hashable {
    public var hashValue: Int {
        switch self {
        case .root:
            return MAGIC_ROOT_VALUE
        case let .node(id, parent):
            return hashCombine(lhv: id.hashValue, rhv: parent.hashValue)
        }
    }
}

extension CompartmentId {
    public static prefix func / (_ id: CompartmentId) -> CompartmentIndex {
        return .node(id: id, parent: CompartmentIndex.root)
    }
}

extension CompartmentIndex {
    public static func / (lhv: CompartmentIndex, rhv: CompartmentId) -> CompartmentIndex {
        return .node(id: rhv, parent: lhv)
    }
}

extension CompartmentId: CustomStringConvertible {
    public var description: String {
        return self.rawValue
    }
}

extension CompartmentIndex: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .node(id, parent):
            return "\(parent) \(id) /"
        case .root:
            return "/"
        }
    }
}

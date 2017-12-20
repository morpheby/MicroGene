//
//  Value.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/12/17.
//

import Foundation

public protocol AnyStorable {
}

public protocol Storable: AnyStorable {
}

public struct MarkerId {

    public var name: String

    public init(name: String) {
        self.name = name + locallyUniqueId()
    }
}

extension MarkerId: RawRepresentable {

    public typealias RawValue = String

    public init?(rawValue: MarkerId.RawValue) {
        self.name = rawValue
    }

    public var rawValue: String {
        return self.name
    }
}

extension MarkerId: Equatable {
    public static func ==(lhv: MarkerId, rhv: MarkerId) -> Bool {
        return lhv.name == rhv.name
    }
}

extension MarkerId: Hashable {
    public var hashValue: Int {
        return self.name.hashValue
    }
}

public struct StorableState {

    public var markers: [MarkerId: Any]

    public init(markers: [MarkerId: Any]) {
        self.markers = markers
    }

    public init() {
        self.init(markers: [:])
    }

    public func marker<T>(for id: MarkerId) -> T? {
        return markers[id] as? T
    }

    public mutating func set<T>(marker: T?, for id: MarkerId) {
        markers[id] = marker
    }
}

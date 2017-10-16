//
//  Definitions.swift
//  MicroGeneTests
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation

@testable import MicroGene

extension CompartmentId {
    static let testId1 = CompartmentId(rawValue: "TestId1")!
    static let testId2 = CompartmentId(rawValue: "TestId2")!
    static let testId3 = CompartmentId(rawValue: "TestId3")!
    static let testId4 = CompartmentId(rawValue: "TestId4")!
}

extension StorableId {
    static let testId1 = StorableId(rawValue: "TestStored1")!
    static let testId2 = StorableId(rawValue: "TestStored2")!
    static let testId3 = StorableId(rawValue: "TestStored3")!
    static let testId4 = StorableId(rawValue: "TestStored4")!

    static let stored1 = StorableId(rawValue: "Stored1")!
    static let stored2 = StorableId(rawValue: "Stored2")!
    static let stored3 = StorableId(rawValue: "Stored3")!
    static let stored4 = StorableId(rawValue: "Stored4")!
}

extension String: Storable { }

extension Int: Storable { }

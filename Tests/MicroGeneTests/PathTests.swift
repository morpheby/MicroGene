//
//  PathTests.swift
//  MicroGeneTests
//
//  Created by Ilya Mikhaltsou on 10/12/17.
//

import Foundation
import XCTest
@testable import MicroGene

class PathTests: XCTestCase {

    func testIndexAndCompartment() {
        // public func || (lhv: CompartmentIndex, rhv: CompartmentId) -> PathRepresentable
        let representable = CompartmentIndex(id: .testId1) || CompartmentId.testId2

        guard let partial = representable as? PathPartial else {
            XCTFail("CompartmentIndex || CompartmentId produced PathRepresentable that is not PathPartial")
            return
        }

        XCTAssertNil(partial.fullPath, "CompartmentIndex || CompartmentId should not have fullPath")

        XCTAssertNotNil(partial.innermostCompartment, "CompartmentIndex || CompartmentId innermostCompartment should not be nil")

        XCTAssertNotNil(partial.innermostCompartment?.parent, "CompartmentIndex || CompartmentId innermostCompartment.parent should not be nil")

        XCTAssertEqual(partial.innermostCompartment?.parent, CompartmentIndex(id: .testId1),
                       "CompartmentIndex || CompartmentId innermostCompartment.parent should equal originally set parent")

        XCTAssertEqual(partial.innermostCompartment, CompartmentIndex(id: .testId2, parent: CompartmentIndex(id: .testId1)),
                       "CompartmentIndex || CompartmentId innermostCompartment should equal originally set compartment")
    }

    func testIndexAndStorable() {
        // public func || (lhv: CompartmentIndex, rhv: StorableId) -> Path
        let path = CompartmentIndex(id: .testId1) || StorableId.testId1

        XCTAssertEqual(path.innermostCompartment, CompartmentIndex(id: .testId1),
                       "CompartmentIndex || StorableId innermostCompartment should equal originally set compartment")

        XCTAssertEqual(path.storable, StorableId.testId1,
                       "CompartmentIndex || StorableId storable should equal originally set storable")
    }

    func testIdAndId() {
        // public func || (lhv: CompartmentId, rhv: CompartmentId) -> PathRepresentable
        let representable = CompartmentId.testId1 || CompartmentId.testId2

        guard let partial = representable as? PathPartial else {
            XCTFail("CompartmentId || CompartmentId produced PathRepresentable that is not PathPartial")
            return
        }

        XCTAssertNil(partial.fullPath, "CompartmentId || CompartmentId should not have fullPath")

        XCTAssertNotNil(partial.innermostCompartment, "CompartmentId || CompartmentId innermostCompartment should not be nil")

        XCTAssertNotNil(partial.innermostCompartment?.parent, "CompartmentId || CompartmentId innermostCompartment.parent should not be nil")

        XCTAssertEqual(partial.innermostCompartment?.parent, CompartmentIndex(id: .testId1),
                       "CompartmentId || CompartmentId innermostCompartment.parent should equal originally set parent")

        XCTAssertEqual(partial.innermostCompartment, CompartmentIndex(id: .testId2, parent: CompartmentIndex(id: .testId1)),
                       "CompartmentId || CompartmentId innermostCompartment should equal originally set compartment")
    }

    func testIdAndStorable() {
        // public func || (lhv: CompartmentId, rhv: StorableId) -> Path
        let path = CompartmentId.testId1 || StorableId.testId1

        XCTAssertEqual(path.innermostCompartment, CompartmentIndex(id: .testId1),
                       "CompartmentId || StorableId innermostCompartment should equal originally set compartment")

        XCTAssertEqual(path.storable, StorableId.testId1,
                       "CompartmentId || StorableId storable should equal originally set storable")
    }

    func testPathReprAndId() {
        // public func || (lhv: PathRepresentable, rhv: CompartmentId) -> PathRepresentable
        let representableOne = CompartmentId.testId3 || CompartmentId.testId1
        let representable = representableOne || CompartmentId.testId2

        guard let partial = representable as? PathPartial else {
            XCTFail("PathRepresentable || CompartmentId produced PathRepresentable that is not PathPartial")
            return
        }

        XCTAssertNil(partial.fullPath, "PathRepresentable || CompartmentId should not have fullPath")

        XCTAssertNotNil(partial.innermostCompartment, "PathRepresentable || CompartmentId innermostCompartment should not be nil")

        XCTAssertNotNil(partial.innermostCompartment?.parent, "PathRepresentable || CompartmentId innermostCompartment.parent should not be nil")

        XCTAssertNotNil(partial.innermostCompartment?.parent?.parent, "PathRepresentable || CompartmentId innermostCompartment.parent.parent should not be nil")

        XCTAssertEqual(partial.innermostCompartment?.parent, CompartmentIndex(id: .testId1, parent: CompartmentIndex(id: .testId3)),
                       "PathRepresentable || CompartmentId innermostCompartment.parent should equal originally set parent")

        XCTAssertEqual(partial.innermostCompartment, CompartmentIndex(id: .testId2, parent: CompartmentIndex(id: .testId1, parent: CompartmentIndex(id: .testId3))),
                       "PathRepresentable || CompartmentId innermostCompartment should equal originally set compartment")
    }

    func testPathReprAndIdSequential() {
        // public func || (lhv: PathRepresentable, rhv: CompartmentId) -> PathRepresentable
        let representable = CompartmentId.testId3 || CompartmentId.testId1 || CompartmentId.testId2

        guard let partial = representable as? PathPartial else {
            XCTFail("PathRepresentable || CompartmentId produced PathRepresentable that is not PathPartial")
            return
        }

        XCTAssertNil(partial.fullPath, "PathRepresentable || CompartmentId should not have fullPath")

        XCTAssertNotNil(partial.innermostCompartment, "PathRepresentable || CompartmentId innermostCompartment should not be nil")

        XCTAssertNotNil(partial.innermostCompartment?.parent, "PathRepresentable || CompartmentId innermostCompartment.parent should not be nil")

        XCTAssertNotNil(partial.innermostCompartment?.parent?.parent, "PathRepresentable || CompartmentId innermostCompartment.parent.parent should not be nil")

        XCTAssertEqual(partial.innermostCompartment?.parent, CompartmentIndex(id: .testId1, parent: CompartmentIndex(id: .testId3)),
                       "PathRepresentable || CompartmentId innermostCompartment.parent should equal originally set parent")

        XCTAssertEqual(partial.innermostCompartment, CompartmentIndex(id: .testId2, parent: CompartmentIndex(id: .testId1, parent: CompartmentIndex(id: .testId3))),
                       "PathRepresentable || CompartmentId innermostCompartment should equal originally set compartment")
    }

    func testPathReprAndStorable() {
        // public func || (lhv: PathRepresentable, rhv: StorableId) -> Path
        let representable = CompartmentId.testId1 || CompartmentId.testId2
        let path = representable || StorableId.testId1

        XCTAssertEqual(path.innermostCompartment, CompartmentIndex(id: .testId2, parent: CompartmentIndex(id: .testId1)),
                       "PathRepresentable || StorableId innermostCompartment should equal originally set compartment")

        XCTAssertEqual(path.storable, StorableId.testId1,
                       "PathRepresentable || StorableId storable should equal originally set storable")
    }

    func testPathReprAndStorableSequential() {
        // public func || (lhv: PathRepresentable, rhv: StorableId) -> Path
        let path = CompartmentId.testId1 || CompartmentId.testId2 || StorableId.testId1

        XCTAssertEqual(path.innermostCompartment, CompartmentIndex(id: .testId2, parent: CompartmentIndex(id: .testId1)),
                       "PathRepresentable || StorableId innermostCompartment should equal originally set compartment")

        XCTAssertEqual(path.storable, StorableId.testId1,
                       "PathRepresentable || StorableId storable should equal originally set storable")
    }

    static var allTests = [
        ("testIndexAndCompartment", testIndexAndCompartment),
        ("testIndexAndStorable", testIndexAndStorable),
        ("testIdAndId", testIdAndId),
        ("testIdAndStorable", testIdAndStorable),
        ("testPathReprAndId", testPathReprAndId),
        ("testPathReprAndIdSequential", testPathReprAndIdSequential),
        ("testPathReprAndStorable", testPathReprAndStorable),
        ("testPathReprAndStorableSequential", testPathReprAndStorableSequential),
    ]
}

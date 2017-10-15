//
//  CompartmentIndexTests.swift
//  MicroGeneTests
//
//  Created by Ilya Mikhaltsou on 10/12/17.
//

import Foundation
import XCTest
@testable import MicroGene

class CompartmentIndexTests: XCTestCase {

    func testCompartmentIdEquals() {
        let one = CompartmentId(rawValue: "AAA")
        let two = CompartmentId(rawValue: "AAA")

        XCTAssertEqual(one, two, "CompartmentId(\"AAA\") should equal CompartmentId(\"AAA\")")
    }

    func testCompartmentIdNotEquals() {
        let one = CompartmentId(rawValue: "AAA")
        let two = CompartmentId(rawValue: "BBB")

        XCTAssertNotEqual(one, two, "CompartmentId(\"AAA\") should not equal CompartmentId(\"BBB\")")
    }

    func testCompartmentIdHash() {
        let one = CompartmentId(rawValue: "AAA")!
        let two = CompartmentId(rawValue: "AAA")!

        XCTAssertEqual(one.hashValue, two.hashValue, "CompartmentId with same rawValue should have same hashValue")

        var found: Int? = nil
        for i in 0..<1000 {
            let three = CompartmentId(rawValue: "\(i)")!
            if three.hashValue != two.hashValue {
                found = i
                break
            }
        }

        XCTAssertNotNil(found, "CompartmentId should have at least one hashValue differing with different rawValue's")
        debugPrint("NOTE: found different hashValue at i=\(found!)")
    }

    func testStorabletIdEquals() {
        let one = StorableId(rawValue: "AAA")
        let two = StorableId(rawValue: "AAA")

        XCTAssertEqual(one, two, "StorableId(\"AAA\") should equal StorableId(\"AAA\")")
    }

    func testStorableIdNotEquals() {
        let one = StorableId(rawValue: "AAA")
        let two = StorableId(rawValue: "BBB")

        XCTAssertNotEqual(one, two, "StorableId(\"AAA\") should not equal StorableId(\"BBB\")")
    }

    func testStorableIdHash() {
        let one = StorableId(rawValue: "AAA")!
        let two = StorableId(rawValue: "AAA")!

        XCTAssertEqual(one.hashValue, two.hashValue, "StorableId with same rawValue should have same hashValue")

        var found: Int? = nil
        for i in 0..<1000 {
            let three = StorableId(rawValue: "\(i)")!
            if three.hashValue != two.hashValue {
                found = i
                break
            }
        }

        XCTAssertNotNil(found, "StorableId should have at least one hashValue differing with different rawValue's")
        debugPrint("NOTE: found different hashValue at i=\(found!)")
    }

    func testIndexEquals() {
        let one = CompartmentIndex.node(id: CompartmentId.testId1, parent: .root)
        let two = CompartmentIndex.node(id: CompartmentId.testId1, parent: .root)
        XCTAssertEqual(one, two, "CompartmentIndex'es referencing same CompartmentId should be equal")
    }

    func testIndexEqualsNonReference() {
        let parentOne = CompartmentIndex.node(id: CompartmentId.testId1, parent: .root)
        let parentTwo = CompartmentIndex.node(id: CompartmentId.testId1, parent: .root)

        let one = CompartmentIndex.node(id: CompartmentId(rawValue: "TestTest")!, parent: parentOne)
        let two = CompartmentIndex.node(id: CompartmentId(rawValue: "TestTest")!, parent: parentTwo)
        XCTAssertEqual(one, two, "CompartmentIndex'es referencing same CompartmentId and having equal parents should be equal")
    }
    
    func testIndexNotEqualsOnlyId() {
        let one = CompartmentIndex.node(id: CompartmentId.testId1, parent: .root)
        let two = CompartmentIndex.node(id: CompartmentId.testId2, parent: .root)
        XCTAssertNotEqual(one, two, "CompartmentIndex'es referencing different CompartmentId's should not be equal")
    }

    func testIndexNotEquals() {
        let parentOne = CompartmentIndex.node(id: CompartmentId.testId1, parent: .root)
        let parentTwo = CompartmentIndex.node(id: CompartmentId.testId2, parent: .root)

        let one = CompartmentIndex.node(id: CompartmentId.testId3, parent: parentOne)
        let two = CompartmentIndex.node(id: CompartmentId.testId3, parent: parentTwo)
        XCTAssertNotEqual(one, two, "CompartmentIndex'es referencing same CompartmentId but having different parents should not be equal")

        let three = CompartmentIndex.node(id: CompartmentId.testId3, parent: parentOne)
        let four = CompartmentIndex.node(id: CompartmentId.testId4, parent: parentOne)
        XCTAssertNotEqual(three, four, "CompartmentIndex'es referencing different CompartmentId's but having same parent should not be equal")

        let five = CompartmentIndex.node(id: CompartmentId.testId3, parent: parentOne)
        let six = CompartmentIndex.node(id: CompartmentId.testId4, parent: parentTwo)
        XCTAssertNotEqual(five, six, "CompartmentIndex'es referencing different CompartmentId's and different parents should not be equal")
    }

    func testCompartmentInit() {
        let compartment = /.testId1

        guard case let .node(id, parent) = compartment else {
            XCTFail("/CompartmentId should be .node")
            return
        }

        XCTAssertEqual(id, .testId1, "/CompartmentId should produce correct id")

        XCTAssertEqual(parent, .root, "/CompartmentId parent should equal .root")
    }

    func testCompartmentPath() {
        let compartment = /.testId1 / CompartmentId.testId2

        guard case let .node(id, parent) = compartment else {
            XCTFail("CompartmentIndex / CompartmentId should be .node")
            return
        }

        XCTAssertEqual(id, .testId2, "CompartmentIndex / CompartmentId should produce correct id")

        XCTAssertEqual(parent, CompartmentIndex.node(id: .testId1, parent: .root),
                       "CompartmentIndex / CompartmentId parent should equal originally set parent")

        XCTAssertEqual(compartment, CompartmentIndex.node(id: .testId2, parent: CompartmentIndex.node(id: .testId1, parent: .root)),
                       "CompartmentIndex / CompartmentId should equal originally set compartment")
    }

    static var allTests = [
        ("testCompartmentIdEquals", testCompartmentIdEquals),
        ("testCompartmentIdNotEquals", testCompartmentIdNotEquals),
        ("testCompartmentIdHash", testCompartmentIdHash),
        ("testIndexNotEqualsOnlyId", testIndexNotEqualsOnlyId),
        ("testIndexEquals", testIndexEquals),
        ("testIndexEqualsNonReference", testIndexEqualsNonReference),
        ("testIndexNotEquals", testIndexNotEquals),
        ("testCompartmentInit", testCompartmentInit),
        ("testCompartmentPath", testCompartmentPath),
    ]
}



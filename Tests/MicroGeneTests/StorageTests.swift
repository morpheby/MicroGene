//
//  StorageTests.swift
//  MicroGeneTests
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation
import XCTest
@testable import MicroGene

class StorageTests: XCTestCase {

    func testPutTake() {
        let storage = Storage()

        let data = "ABC"

        let pretakenData: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertNil(pretakenData, "Storage.take should return nil when data is not present at path")

        storage.put(data: data, to: /.testId1 / .testId1)

        let takenData: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertEqual(data, takenData, "Storage.take should return exactly what was Storage.put at same path")

        let retakenData: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertNil(retakenData, "Storage.take should return nil when data was already Storage.taken")

        storage.put(data: data, to: /.testId1 / .testId1)
        let takenDataOne: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertEqual(data, takenDataOne, "Storage.take should return exactly what was Storage.put at same path")

        storage.put(data: data, to: /.testId1 / .testId1)
        let takenDataTwo: String? = storage.take(from: /.testId1 / .testId2)
        XCTAssertNil(takenDataTwo, "Compartments should store different Storable's separately")

        let takenDataThree: String? = storage.take(from: /.testId2 / .testId1)
        XCTAssertNil(takenDataThree, "Compartments should be separate")
    }

    func testPutTakeDeep() {
        let storage = Storage()

        let data = "ABC"

        let pretakenData: String? = storage.take(from: /.testId1 / .testId2 / .testId3 / .testId4 / .stored1)
        XCTAssertNil(pretakenData, "Storage.take should return nil when data is not present at path")

        storage.put(data: data, to: /.testId1 / .testId2 / .testId3 / .testId4 / .stored1)

        let takenData: String? = storage.take(from: /.testId1 / .testId2 / .testId3 / .testId4 / .stored1)
        XCTAssertEqual(data, takenData, "Storage.take should return exactly what was Storage.put at same path")

        let retakenData: String? = storage.take(from: /.testId1 / .testId2 / .testId3 / .testId4 / .stored1)
        XCTAssertNil(retakenData, "Storage.take should return nil when data was already Storage.taken")

        storage.put(data: data, to: /.testId1 / .testId2 / .testId3 / .testId4 / .stored1)
        let takenDataOne: String? = storage.take(from: /.testId1 / .testId2 / .testId3 / .testId4 / .stored1)
        XCTAssertEqual(data, takenDataOne, "Storage.take should return exactly what was Storage.put at same path")

        storage.put(data: data, to: /.testId1 / .testId2 / .testId3 / .testId4 / .stored1)
        let takenDataTwo: String? = storage.take(from: /.testId1 / .testId2 / .testId3 / .testId4 / .stored2)
        XCTAssertNil(takenDataTwo, "Compartments should store different Storable's separately")

        let takenDataThree: String? = storage.take(from: /.testId1 / .testId2 / .testId3 / .testId1 / .stored1)
        XCTAssertNil(takenDataThree, "Compartments should be separate")

        let takenDataFour: String? = storage.take(from: /.testId1 / .testId4 / .testId3 / .testId4 / .stored1)
        XCTAssertNil(takenDataFour, "Compartments should be separate")

        let takenDataFive: String? = storage.take(from: /.testId3 / .testId2 / .testId3 / .testId4 / .stored1)
        XCTAssertNil(takenDataFive, "Compartments should be separate")
    }

    class Delegate: StorageDelegate {
        let onPut: (Storage, Path, AnyStorable) -> ()
        let onTake: (Storage, Path, AnyStorable) -> ()

        init(onPut: @escaping (Storage, Path, AnyStorable) -> (), onTake: @escaping (Storage, Path, AnyStorable) -> ()) {
            self.onPut = onPut
            self.onTake = onTake
        }

        func didPutValue(storage: Storage, for path: Path, value: AnyStorable) {
            self.onPut(storage, path, value)
        }

        func didTakeValue(storage: Storage, for path: Path, value: AnyStorable) {
            self.onTake(storage, path, value)
        }
    }

    func testDelegateTakePut() {
        let storage = Storage()

        let data = "ABC"
        let path: Path = /.testId1 / .testId1

        var didPut = false
        var didTake = false

        storage.delegate = Delegate(onPut: { (t, p, s) in
            didPut = true
            XCTAssert(t === storage, "Storage.put should call delegate with self")
            XCTAssert(p == path, "Storage.put should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "Storage.put should call delegate with correct value")
        }, onTake: { (t, p, s) in
            didTake = true
            XCTAssert(t === storage, "Storage.take should call delegate with self")
            XCTAssert(p == path, "Storage.take should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "Storage.take should call delegate with correct value")
        })

        didTake = false
        didPut = false
        let _: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertFalse(didTake, "Storage.take should not call didTake when no value was taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")

        didTake = false
        didPut = false
        storage.put(data: data, to: /.testId1 / .testId1)
        XCTAssertTrue(didPut, "Storage.put should call didPut when value was put")
        XCTAssertFalse(didTake, "Storage.put should not call didTake")

        didTake = false
        didPut = false
        let _: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertTrue(didTake, "Storage.take should call didTake when value was taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")

        didTake = false
        didPut = false
        let _: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertFalse(didTake, "Storage.take should not call didTake when value was already taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")

        didTake = false
        didPut = false
        storage.put(data: data, to: /.testId1 / .testId1)
        XCTAssertTrue(didPut, "Storage.put should call didPut when value was put")
        XCTAssertFalse(didTake, "Storage.put should not call didTake")

        didTake = false
        didPut = false
        let _: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertTrue(didTake, "Storage.take should call didTake when value was taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")

        didTake = false
        didPut = false
        let _: String? = storage.take(from: /.testId1 / .testId2)
        XCTAssertFalse(didTake, "Storage.take should not call didTake when no value was taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")

        didTake = false
        didPut = false
        let _: String? = storage.take(from: /.testId2 / .testId1)
        XCTAssertFalse(didTake, "Storage.take should not call didTake when no value was taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")
    }

    func testDelegateTakeInPut() {
        let storage = Storage()

        let data = "ABC"
        let path: Path = /.testId1 / .testId1

        var didPut = false
        var didTake = false

        storage.delegate = Delegate(onPut: { (t, p, s) in
            didPut = true
            XCTAssert(t === storage, "Storage.put should call delegate with self")
            XCTAssert(p == path, "Storage.put should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "Storage.put should call delegate with correct value")

            let takenData: String? = t.take(from: p)
            XCTAssertEqual(data, takenData, "Storage.take should return exactly what was Storage.put at same path")
        }, onTake: { (t, p, s) in
            didTake = true
            XCTAssert(t === storage, "Storage.take should call delegate with self")
            XCTAssert(p == path, "Storage.take should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "Storage.take should call delegate with correct value")
        })

        didTake = false
        didPut = false
        storage.put(data: data, to: /.testId1 / .testId1)
        XCTAssertTrue(didPut, "Storage.put should call didPut when value was put")
        XCTAssertTrue(didTake, "Storage.take should have succeeded")

        didTake = false
        didPut = false
        let _: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertFalse(didTake, "Storage.take should not call didTake when value was already taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")
    }

    func testDelegatePutInTake() {
        let storage = Storage()

        let data = "ABC"
        let path: Path = /.testId1 / .testId1

        var didPut = false
        var didTake = false

        storage.delegate = Delegate(onPut: { (t, p, s) in
            didPut = true
            XCTAssert(t === storage, "Storage.put should call delegate with self")
            XCTAssert(p == path, "Storage.put should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "Storage.put should call delegate with correct value")
        }, onTake: { (t, p, s) in
            didTake = true
            XCTAssert(t === storage, "Storage.take should call delegate with self")
            XCTAssert(p == path, "Storage.take should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "Storage.take should call delegate with correct value")

            t.put(data: data, to: p)
        })

        didTake = false
        didPut = false
        storage.put(data: data, to: /.testId1 / .testId1)
        XCTAssertTrue(didPut, "Storage.put should call didPut when value was put")
        XCTAssertFalse(didTake, "Storage.put should not call didTake")

        didTake = false
        didPut = false
        let _: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertTrue(didTake, "Storage.take should call didTake when value was taken")
        XCTAssertTrue(didPut, "Storage.put should have succeeded")

        storage.delegate = Delegate(onPut: { (t, p, s) in
            didPut = true
            XCTAssert(t === storage, "Storage.put should call delegate with self")
            XCTAssert(p == path, "Storage.put should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "Storage.put should call delegate with correct value")
        }, onTake: { (t, p, s) in
            didTake = true
            XCTAssert(t === storage, "Storage.take should call delegate with self")
            XCTAssert(p == path, "Storage.take should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "Storage.take should call delegate with correct value")
        })

        didTake = false
        didPut = false
        let _: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertTrue(didTake, "Storage.take should call didTake when value was taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")
    }

    func testMultiStorage() {
        let storage = Storage()

        let dataOne = "ABC"
        let dataTwo = "ABCD"
        let dataThree = 5

        let pretakenData: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertNil(pretakenData, "Storage.take should return nil when data is not present at path")

        storage.put(data: dataOne, to: /.testId1 / .testId1)

        let takenData: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertEqual(dataOne, takenData, "Storage.take should return exactly what was Storage.put at same path")

        let retakenData: String? = storage.take(from: /.testId1 / .testId1)
        XCTAssertNil(retakenData, "Storage.take should return nil when data was already Storage.taken")

        storage.put(data: dataOne, to: /.testId1 / .testId1)
        storage.put(data: dataTwo, to: /.testId1 / .testId1)
        storage.put(data: dataThree, to: /.testId1 / .testId1)
        let takenDataOne: String? = storage.take(from: /.testId1 / .testId1)
        let takenDataTwo: String? = storage.take(from: /.testId1 / .testId1)
        let takenDataThree: Int? = storage.take(from: /.testId1 / .testId1)

        let allData = Set([AnyHashable(dataOne), AnyHashable(dataTwo), AnyHashable(dataThree)])
        let allTakenData = Set([takenDataOne.map{AnyHashable($0)}, takenDataTwo.map{AnyHashable($0)}, takenDataThree.map{AnyHashable($0)}].flatten())
        XCTAssertEqual(allData, allTakenData, "Storage.take should return exactly what was Storage.put at same path")
    }

    static var allTests = [
        ("testPutTake", testPutTake),
        ("testPutTakeDeep", testPutTakeDeep),
        ("testDelegateTakePut", testDelegateTakePut),
        ("testDelegateTakeInPut", testDelegateTakeInPut),
        ("testDelegatePutInTake", testDelegatePutInTake),
        ("testMultiStorage", testMultiStorage),
    ]
}

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

        let pretakenData = storage.take(from: /.testId1 / .testId1)
        XCTAssertNil(pretakenData, "Storage.take should return nil when data is not present at path")

        storage.put(data: data, to: /.testId1 / .testId1)

        let takenData = storage.take(from: /.testId1 / .testId1)
        XCTAssertEqual(data, takenData as? String, "Storage.take should return exactly what was Storage.put at same path")

        let retakenData = storage.take(from: /.testId1 / .testId1)
        XCTAssertNil(retakenData, "Storage.take should return nil when data was already Storage.taken")

        storage.put(data: data, to: /.testId1 / .testId1)
        let takenDataOne = storage.take(from: /.testId1 / .testId1)
        XCTAssertEqual(data, takenDataOne as? String, "Storage.take should return exactly what was Storage.put at same path")

        storage.put(data: data, to: /.testId1 / .testId1)
        let takenDataTwo = storage.take(from: /.testId1 / .testId2)
        XCTAssertNil(takenDataTwo, "Compartments should store different 's separately")

        let takenDataThree = storage.take(from: /.testId2 / .testId1)
        XCTAssertNil(takenDataThree, "Compartments should be separate")
    }

    class Delegate: StorageDelegate {
        let onPut: (Storage, Path, Storable) -> ()
        let onTake: (Storage, Path, Storable) -> ()

        init(onPut: @escaping (Storage, Path, Storable) -> (), onTake: @escaping (Storage, Path, Storable) -> ()) {
            self.onPut = onPut
            self.onTake = onTake
        }

        func didPutValue(storage: Storage, for path: Path, value: Storable) {
            self.onPut(storage, path, value)
        }

        func didTakeValue(storage: Storage, for path: Path, value: Storable) {
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
        let _ = storage.take(from: /.testId1 / .testId1)
        XCTAssertFalse(didTake, "Storage.take should not call didTake when no value was taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")

        didTake = false
        didPut = false
        storage.put(data: data, to: /.testId1 / .testId1)
        XCTAssertTrue(didPut, "Storage.put should call didPut when value was put")
        XCTAssertFalse(didTake, "Storage.put should not call didTake")

        didTake = false
        didPut = false
        let _ = storage.take(from: /.testId1 / .testId1)
        XCTAssertTrue(didTake, "Storage.take should call didTake when value was taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")

        didTake = false
        didPut = false
        let _ = storage.take(from: /.testId1 / .testId1)
        XCTAssertFalse(didTake, "Storage.take should not call didTake when value was already taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")

        didTake = false
        didPut = false
        storage.put(data: data, to: /.testId1 / .testId1)
        XCTAssertTrue(didPut, "Storage.put should call didPut when value was put")
        XCTAssertFalse(didTake, "Storage.put should not call didTake")

        didTake = false
        didPut = false
        let _ = storage.take(from: /.testId1 / .testId1)
        XCTAssertTrue(didTake, "Storage.take should call didTake when value was taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")

        didTake = false
        didPut = false
        let _ = storage.take(from: /.testId1 / .testId2)
        XCTAssertFalse(didTake, "Storage.take should not call didTake when no value was taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")

        didTake = false
        didPut = false
        let _ = storage.take(from: /.testId2 / .testId1)
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

            let takenData = t.take(from: p)
            XCTAssertEqual(data, takenData as? String, "Storage.take should return exactly what was Storage.put at same path")
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
        let _ = storage.take(from: /.testId1 / .testId1)
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
        let _ = storage.take(from: /.testId1 / .testId1)
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
        let _ = storage.take(from: /.testId1 / .testId1)
        XCTAssertTrue(didTake, "Storage.take should call didTake when value was taken")
        XCTAssertFalse(didPut, "Storage.take should not call didPut")
    }

    static var allTests = [
        ("testPutTake", testPutTake),
        ("testDelegateTakePut", testDelegateTakePut),
        ("testDelegateTakeInPut", testDelegateTakeInPut),
        ("testDelegatePutInTake", testDelegatePutInTake),
    ]
}

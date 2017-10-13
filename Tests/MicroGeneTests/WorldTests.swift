//
//  WorldTests.swift
//  MicroGeneTests
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation
import XCTest
@testable import MicroGene

class WorldTests: XCTestCase {

    func testPutTake() {
        let world = World()

        let data = "ABC"

        let pretakenData = world.take(from: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertNil(pretakenData, "World.take should return nil when data is not present at path")

        world.put(data: data, to: CompartmentId.testId1 || StorableId.testId1)

        let takenData = world.take(from: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertEqual(data, takenData as? String, "World.take should return exactly what was World.put at same path")

        let retakenData = world.take(from: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertNil(retakenData, "World.take should return nil when data was already World.taken")

        world.put(data: data, to: CompartmentId.testId1 || StorableId.testId1)
        let takenDataOne = world.take(from: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertEqual(data, takenDataOne as? String, "World.take should return exactly what was World.put at same path")

        world.put(data: data, to: CompartmentId.testId1 || StorableId.testId1)
        let takenDataTwo = world.take(from: CompartmentId.testId1 || StorableId.testId2)
        XCTAssertNil(takenDataTwo, "Compartments should store different StorableId's separately")

        let takenDataThree = world.take(from: CompartmentId.testId2 || StorableId.testId1)
        XCTAssertNil(takenDataThree, "Compartments should be separate")
    }

    class Delegate: WorldDelegate {
        let onPut: (World, Path, Storable) -> ()
        let onTake: (World, Path, Storable) -> ()

        init(onPut: @escaping (World, Path, Storable) -> (), onTake: @escaping (World, Path, Storable) -> ()) {
            self.onPut = onPut
            self.onTake = onTake
        }

        func didPutValue(world: World, for path: Path, value: Storable) {
            self.onPut(world, path, value)
        }

        func didTakeValue(world: World, for path: Path, value: Storable) {
            self.onTake(world, path, value)
        }
    }

    func testDelegateTakePut() {
        let world = World()

        let data = "ABC"
        let path = CompartmentId.testId1 || StorableId.testId1

        var didPut = false
        var didTake = false

        world.delegate = Delegate(onPut: { (w, p, s) in
            didPut = true
            XCTAssert(w === world, "World.put should call delegate with self")
            XCTAssert(p.storable == path.storable && p.innermostCompartment == path.innermostCompartment, "World.put should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "World.put should call delegate with correct value")
        }, onTake: { (w, p, s) in
            didTake = true
            XCTAssert(w === world, "World.take should call delegate with self")
            XCTAssert(p.storable == path.storable && p.innermostCompartment == path.innermostCompartment, "World.take should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "World.take should call delegate with correct value")
        })

        didTake = false
        didPut = false
        let _ = world.take(from: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertFalse(didTake, "World.take should not call didTake when no value was taken")
        XCTAssertFalse(didPut, "World.take should not call didPut")

        didTake = false
        didPut = false
        world.put(data: data, to: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertTrue(didPut, "World.put should call didPut when value was put")
        XCTAssertFalse(didTake, "World.put should not call didTake")

        didTake = false
        didPut = false
        let _ = world.take(from: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertTrue(didTake, "World.take should call didTake when value was taken")
        XCTAssertFalse(didPut, "World.take should not call didPut")

        didTake = false
        didPut = false
        let _ = world.take(from: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertFalse(didTake, "World.take should not call didTake when value was already taken")
        XCTAssertFalse(didPut, "World.take should not call didPut")

        didTake = false
        didPut = false
        world.put(data: data, to: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertTrue(didPut, "World.put should call didPut when value was put")
        XCTAssertFalse(didTake, "World.put should not call didTake")

        didTake = false
        didPut = false
        let _ = world.take(from: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertTrue(didTake, "World.take should call didTake when value was taken")
        XCTAssertFalse(didPut, "World.take should not call didPut")

        didTake = false
        didPut = false
        let _ = world.take(from: CompartmentId.testId1 || StorableId.testId2)
        XCTAssertFalse(didTake, "World.take should not call didTake when no value was taken")
        XCTAssertFalse(didPut, "World.take should not call didPut")

        didTake = false
        didPut = false
        let _ = world.take(from: CompartmentId.testId2 || StorableId.testId1)
        XCTAssertFalse(didTake, "World.take should not call didTake when no value was taken")
        XCTAssertFalse(didPut, "World.take should not call didPut")
    }

    func testDelegateTakeInPut() {
        let world = World()

        let data = "ABC"
        let path = CompartmentId.testId1 || StorableId.testId1

        var didPut = false
        var didTake = false

        world.delegate = Delegate(onPut: { (w, p, s) in
            didPut = true
            XCTAssert(w === world, "World.put should call delegate with self")
            XCTAssert(p.storable == path.storable && p.innermostCompartment == path.innermostCompartment, "World.put should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "World.put should call delegate with correct value")

            let takenData = w.take(from: p)
            XCTAssertEqual(data, takenData as? String, "World.take should return exactly what was World.put at same path")
        }, onTake: { (w, p, s) in
            didTake = true
            XCTAssert(w === world, "World.take should call delegate with self")
            XCTAssert(p.storable == path.storable && p.innermostCompartment == path.innermostCompartment, "World.take should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "World.take should call delegate with correct value")
        })

        didTake = false
        didPut = false
        world.put(data: data, to: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertTrue(didPut, "World.put should call didPut when value was put")
        XCTAssertTrue(didTake, "World.take should have succeeded")

        didTake = false
        didPut = false
        let _ = world.take(from: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertFalse(didTake, "World.take should not call didTake when value was already taken")
        XCTAssertFalse(didPut, "World.take should not call didPut")
    }

    func testDelegatePutInTake() {
        let world = World()

        let data = "ABC"
        let path = CompartmentId.testId1 || StorableId.testId1

        var didPut = false
        var didTake = false

        world.delegate = Delegate(onPut: { (w, p, s) in
            didPut = true
            XCTAssert(w === world, "World.put should call delegate with self")
            XCTAssert(p.storable == path.storable && p.innermostCompartment == path.innermostCompartment, "World.put should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "World.put should call delegate with correct value")
        }, onTake: { (w, p, s) in
            didTake = true
            XCTAssert(w === world, "World.take should call delegate with self")
            XCTAssert(p.storable == path.storable && p.innermostCompartment == path.innermostCompartment, "World.take should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "World.take should call delegate with correct value")

            w.put(data: data, to: p)
        })

        didTake = false
        didPut = false
        world.put(data: data, to: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertTrue(didPut, "World.put should call didPut when value was put")
        XCTAssertFalse(didTake, "World.put should not call didTake")

        didTake = false
        didPut = false
        let _ = world.take(from: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertTrue(didTake, "World.take should call didTake when value was taken")
        XCTAssertTrue(didPut, "World.put should have succeeded")

        world.delegate = Delegate(onPut: { (w, p, s) in
            didPut = true
            XCTAssert(w === world, "World.put should call delegate with self")
            XCTAssert(p.storable == path.storable && p.innermostCompartment == path.innermostCompartment, "World.put should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "World.put should call delegate with correct value")
        }, onTake: { (w, p, s) in
            didTake = true
            XCTAssert(w === world, "World.take should call delegate with self")
            XCTAssert(p.storable == path.storable && p.innermostCompartment == path.innermostCompartment, "World.take should call delegate with correct path")
            XCTAssertEqual(s as? String, data, "World.take should call delegate with correct value")
        })

        didTake = false
        didPut = false
        let _ = world.take(from: CompartmentId.testId1 || StorableId.testId1)
        XCTAssertTrue(didTake, "World.take should call didTake when value was taken")
        XCTAssertFalse(didPut, "World.take should not call didPut")
    }

    static var allTests = [
        ("testPutTake", testPutTake),
        ("testDelegateTakePut", testDelegateTakePut),
        ("testDelegateTakeInPut", testDelegateTakeInPut),
        ("testDelegatePutInTake", testDelegatePutInTake),
    ]
}

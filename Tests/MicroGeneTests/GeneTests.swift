//
//  GeneTests.swift
//  MicroGeneTests
//
//  Created by Ilya Mikhaltsou on 10/20/17.
//

import Foundation
import XCTest
@testable import MicroGene

fileprivate var finalValue: Int?

class GeneTests: XCTestCase {

    let _regPlaceholder = allGenesRegistration

    func testGenes() {
        finalValue = nil

        let system = System()

        system.startAndLock()

        XCTAssert(finalValue == 190392490709135, "Invalid final number after running GeneSystem")
    }

    func testMockProfile() {
        measure {
            var f: ((Int, Int, Int) -> (Int))!
            f = { x, y, i in
                guard i > 0 else { return x }
                return f(x+y, x, i - 1)
            }
            XCTAssert(f(0,1,70) == 190392490709135, "Invalid final number after running mock function")
        }
    }

    func testGenesProfile() {
        measure {
            finalValue = nil

            let system = System()

            system.startAndLock()

            XCTAssert(finalValue == 190392490709135, "Invalid final number after running GeneSystem")
        }
    }

    static var allTests = [
        ("testGenes", testGenes),
    ]
}

struct IntValue: Storable {
    var value: Int
}

internal let allGenesRegistration = [
    registerGene(TestGene1.self),
    registerGene(TestGene2.self),
    registerGene(TestGene3.self),
]

class TestGene1: Gene {
    public static let bindings: [AnyVariableBinding] = [
        !.microgeneEntry <> \TestGene1.entry,
    ]

    public var entry = Var(Entry.self)

    public static let priority = Priority.higher(than: Startup.priority)

    public required init() { }

    public func match() -> Bool {
        return true
    }

    open func execute() -> [AnyOutput] {
        debugPrint("Startup successful")
        return [
            Output(value: IntValue(value: 0), to: /.testId1 / .stored1),
            Output(value: IntValue(value: 1), to: /.testId1 / .stored2),
            Output(value: IntValue(value: 70), to: /.testId1 / .stored3),
        ]
    }
}

class TestGene2: Gene {
    public static let bindings: [AnyVariableBinding] = [
        /.any / !.stored1 <> \TestGene2.x,
        /.any / !.stored2 <> \TestGene2.y,
        /.any / !.stored3 <> \TestGene2.i,
    ]

    var x = Var(IntValue.self)
    var y = Var(IntValue.self)
    var i = Var(IntValue.self)

    public static let priority = Priority.normal

    public required init() { }

    public func match() -> Bool {
        return i.value.value > 0
    }

    open func execute() -> [AnyOutput] {
        let x = self.x.value.value
        let y = self.y.value.value
        let i = self.i.value.value

        let newX = x + y
        let newY = x
        let newI = i - 1
        return [
            Output(value: IntValue(value: newX), to: /.testId2 / .stored1),
            Output(value: IntValue(value: newY), to: /.testId2 / .stored2),
            Output(value: IntValue(value: newI), to: /.testId2 / .stored3),
        ]
    }
}


class TestGene3: Gene {
    public static let bindings: [AnyVariableBinding] = [
        /.any / !.stored1 <> \TestGene3.x,
        /.any / !.stored3 <> \TestGene3.i
    ]

    var i = Var(IntValue.self)
    var x = Var(IntValue.self)

    open static let priority = Priority.normal

    public required init() { }

    public func match() -> Bool {
        return i.value.value == 0
    }

    open func execute() -> [AnyOutput] {
        debugPrint("Exiting")
        finalValue = x.value.value
        return [
            Output(value: Exit(), to: .microgeneExit)
        ]
    }
}

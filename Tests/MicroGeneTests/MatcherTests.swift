//
//  MatcherTests.swift
//  MicroGeneTests
//
//  Created by Ilya Mikhaltsou on 10/16/17.
//

import Foundation
import XCTest
@testable import MicroGene

class MatcherTests: XCTestCase {

    private var matched = false
    static fileprivate var checked = false

    let paths: [Path] = [
        /.testId1 / .stored1,
        /.testId2 / .stored1,
        /.testId2 / .stored2,
        /.testId1 / .stored2,

        /.testId1 / .testId2 / .testId1 / .stored1,
        /.testId1 / .testId2 / .testId1 / .stored2,
        /.testId1 / .testId2 / .testId2 / .stored1,
        /.testId1 / .testId2 / .testId2 / .stored3,

        /.testId1 / .testId4 / .testId3 / .testId2 / .testId1 / .testId4 / .stored1,
        /.testId1 / .testId2 / .testId3 / .testId2 / .testId1 / .testId2 / .testId4 / .stored1,
        /.testId1 / .testId2 / .testId3 / .testId2 / .testId1 / .testId2 / .testId4 / .stored2,
        /.testId2 / .testId2 / .testId3 / .testId2 / .testId1 / .testId2 / .testId4 / .stored1,
    ]

    struct Match1: Matchable {
        static let bindings: [AnyVariableBinding] = [
            /.any / !.stored1 <> \Match1.test1,
            /.any / !.stored2 <> \Match1.test2,
        ]

        static let priority = Priority.normal

        var test1 = Var(String.self)
        var test2 = Var(String.self)

        init() {}

        func match() -> Bool {
            return true
        }

        func equals(_ v: (String, String)) -> Bool {
            return v == (test1.value, test2.value)
        }
    }

    var storage = Storage()

    func setupMatcher() -> Matcher {
        let matcher = Matcher()

        matcher.register(Match1.self) { m in
            XCTAssert(m.equals(("ABC", "CDE")), "Match1 failed")
            self.matched = true
        }

        return matcher
    }

    func testMatcherSimple() {
        matched = false
        let matcher = setupMatcher()

        let abc = "ABC"
        let cde = "CDE"

        XCTAssertFalse(matched, "Too early")

        if !matcher.match(value: CompleteValue(abc), at: /.testId1 / .stored1, in: storage) {
            storage.put(data: CompleteValue(abc), to: /.testId1 / .stored1)
        } else { XCTFail("Match shouldn't have happened") }
        XCTAssertFalse(matched, "Too early")

        if !matcher.match(value: CompleteValue(abc), at: /.testId1 / .stored1, in: storage) {
            storage.put(data: CompleteValue(abc), to: /.testId1 / .stored1)
        } else { XCTFail("Match shouldn't have happened") }
        XCTAssertFalse(matched, "Too early")

        if !matcher.match(value: CompleteValue(cde), at: /.testId1 / .stored2, in: storage) {
            XCTFail("Match should've happened")
            return
        }
        XCTAssertTrue(matched, "Match should've been successful")

        matched = false

        let takenTwo: String? = storage.take(from: /.testId1 / .stored2)?.value
        XCTAssertNil(takenTwo, "Data should've been taken")

        if !matcher.match(value: CompleteValue(cde), at: /.testId1 / .stored2, in: storage) {
            XCTFail("Match should've happened")
            return
        }
        XCTAssertTrue(matched, "Match should've been successful")

        matched = false

        let takenOne: String? = storage.take(from: /.testId1 / .stored1)?.value
        XCTAssertNil(takenOne, "Data should've been taken")

        if !matcher.match(value: CompleteValue(cde), at: /.testId1 / .stored2, in: storage) {
            storage.put(data: CompleteValue(cde), to: /.testId1 / .stored2)
        } else { XCTFail("Match shouldn't have happened") }
        XCTAssertFalse(matched, "Too early")

        if !matcher.match(value: CompleteValue(abc), at: /.testId1 / .stored1, in: storage) {
            XCTFail("Match should've happened")
            return
        }
        XCTAssertTrue(matched, "Match should've been successful")

        matched = false
    }

    static var allTests = [
        ("testMatcherSimple", testMatcherSimple),
    ]
}

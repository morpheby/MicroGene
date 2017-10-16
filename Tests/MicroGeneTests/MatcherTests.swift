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

        static let priority: Int = 100

        var test1: String!
        var test2: String!

        init() {}

        func match() -> Bool {
            return true
        }
    }

    func setupMatcher() -> Matcher {
        let matcher = Matcher()

        return matcher
    }

    static var allTests = [
        (),
    ]
}

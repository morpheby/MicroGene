//
//  PathExpressionTests.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/14/17.
//

import Foundation
import XCTest
@testable import MicroGene

class PathExpressionTests: XCTestCase {
    func testExpressions() {
        let paths: [Path] = [
            /.testId1 / .stored1,
            /.testId2 / .stored1,
            /.testId2 / .stored2,
            /.testId1 / .stored2,

            /.testId1 / .testId2 / .testId1 / .stored1,
            /.testId1 / .testId2 / .testId1 / .stored2,
            /.testId1 / .testId2 / .testId2 / .stored1,

            /.testId1 / .testId4 / .testId3 / .testId2 / .testId1 / .testId4 / .stored1,
            /.testId1 / .testId2 / .testId3 / .testId2 / .testId1 / .testId2 / .testId4 / .stored1,
            /.testId1 / .testId2 / .testId3 / .testId2 / .testId1 / .testId2 / .testId4 / .stored2,
        ]

        let list: [(PathExpression, [Bool])] = [
            ( /.any / .any,
              [true, true, true, true,
               false, false, false,
               false, false, false] ),

            ( !(/.testId1 / .stored1),
              [true, false, false, false,
               false, false, false,
               false, false, false] ),

            ( !(/.testId1) / .any,
              [true, false, false, true,
               false, false, false,
               false, false, false] ),

            ( !(/.testId1 / .testId2) / .any / !.stored1,
              [false, false, false, false,
               true, false, true,
               false, false, false] ),

            ( /(!.testId1) / !.stored1,
              [true, false, false, false,
               false, false, false,
               false, false, false] ),

            ( /.any / !.stored1,
              [true, true, false, false,
               false, false, false,
               false, false, false] ),

            ( /(!.testId1) / .repeating(~/.any) / !.stored1,
              [false, false, false, false,
               true, false, true,
               true, true, false] ),

            ( /(!.testId1) / .repeating(~/(!.testId2) / .any) / !.stored1,
              [false, false, false, false,
               true, false, false,
               false, true, false] ),

            ( /.repeating(~/.any) / !.stored1,
              [true, true, false, false,
               true, false, true,
               true, true, false] ),
        ]

        

    }

    static var allTests = [
        ("testExpressions", testExpressions),
    ]
}

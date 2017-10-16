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
        /.testId2 / .testId2 / .testId3 / .testId2 / .testId1 / .testId2 / .testId4 / .stored1,
    ]

    let list: [(PathExpression, [Bool])] = [
        ( /.any / .any,
          [true, true, true, true,
           false, false, false,
           false, false, false, false] ),

        ( !(/.testId1 / .stored1),
          [true, false, false, false,
           false, false, false,
           false, false, false, false] ),

        ( !(/.testId1) / .any,
          [true, false, false, true,
           false, false, false,
           false, false, false, false] ),

        ( !(/.testId1 / .testId2) / .any / !.stored1,
          [false, false, false, false,
           true, false, true,
           false, false, false, false] ),

        ( /(!.testId1) / !.stored1,
          [true, false, false, false,
           false, false, false,
           false, false, false, false] ),

        ( /.any / !.stored1,
          [true, true, false, false,
           false, false, false,
           false, false, false, false] ),

        ( /(!.testId1) / .repeating(~/.any) / !.stored1,
          [false, false, false, false,
           true, false, true,
           true, true, false, false] ),

        ( /(!.testId1) / .repeating(~/(!.testId2) / .any) / !.stored1,
          [false, false, false, false,
           true, false, true,
           false, true, false, false] ),

        ( /.repeating(~/.any) / !.stored1,
          [true, true, false, false,
           true, false, true,
           true, true, false, true] ),

        ( /(!.testId2) / .repeating(~/.any) / !.stored1,
          [false, false, false, false,
           false, false, false,
           false, false, false, true] ),

        ( /.any / !.stored1 || /.any / !.stored2,
          [true, true, true, true,
           false, false, false,
           false, false, false, false] ),

        ( /.any / .repeating(~/.any) / !.testId2 / .repeating(~/.any) / !.stored1,
          [false, false, false, false,
           false, false, false,
           true, true, false, true] ),

        ( /.any / .repeating(~/.any) / .repeating(~/.any) / !.stored1,
          [false, false, false, false,
           true, false, true,
           true, true, false, true] ),
    ]

    func testExpressions() {
        for (expr, truthTable) in list {
            for (path, truth) in zip(paths, truthTable) {
                XCTAssert(expr.match(path) == truth, "Expression '\(expr)' match '\(path)' should be \(truth)")
            }
        }

    }

    func testTree() {
        // Transpose truth table
        let pathList = paths.map { path -> (Path, [Int]) in
            let allValues: [Int] = list.enumerated().flatMap { i, t -> Int? in
                let (_, truthTable) = t
                let requiredOrNil: Path? = (zip(truthTable, paths).first { truth, p -> Bool in
                    truth && p == path
                })?.1
                return requiredOrNil != nil ? i : nil
            }
            return (path, allValues)
        }

        let allExpressions = list.enumerated().map { i, t -> (PathExpression, Int) in
            let (expr, _) = t
            return (expr, i)
        }

        let tree = PathMatchingTree(expressions: allExpressions)

        for (path, allExpressionIdxs) in pathList {
            let a = Set(allExpressionIdxs)
            let b = Set(tree.allExpressions(satisfying: path))
            let aDiff = a.subtracting(b)
            let bDiff = b.subtracting(a)
            XCTAssertEqual(a, b,
                           """
                Path '\(path)':
                > Expressions \(allExpressions.filter {_,i in aDiff.contains(i)}) were not found.
                > Expressions \(allExpressions.filter {_,i in bDiff.contains(i)}) were found but were not supposed to be.
                """)
        }
    }

    static var allTests = [
        ("testExpressions", testExpressions),
        ("testTree", testTree),
    ]
}

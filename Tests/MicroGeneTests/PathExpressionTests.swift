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
        let list: [PathExpression] = [
            /.any / .any,
            !(/.testId1 / .stored1),
            !(/.testId1) / .any,
            !(/.testId1 / .testId2) / .any / !.stored1,
            /(!.testId1) / !.stored1,
            /.any / !.stored1,
        ]
    }

    static var allTests = [
        ("testExpressions", testExpressions),
    ]
}

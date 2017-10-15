//
//  PathTests.swift
//  MicroGeneTests
//
//  Created by Ilya Mikhaltsou on 10/12/17.
//

import Foundation
import XCTest
@testable import MicroGene

class PathTests: XCTestCase {
    func testIndexAndStorable() {
        let path: Path = /.testId1 / .testId1

        XCTAssertEqual(path.compartment, /.testId1,
                       "CompartmentIndex / StorableId compartment should equal originally set compartment")

        XCTAssertEqual(path.storable, .testId1,
                       "CompartmentIndex / StorableId storable should equal originally set storable")
    }

    static var allTests = [
        ("testIndexAndStorable", testIndexAndStorable),
    ]
}

//
//  LUSolverTests.swift
//  SwifyPyTests
//
//  Created by Toni Kocjan on 09/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import XCTest
@testable import SwifyPy

class LUSolverTests: XCTestCase {
  func testSolveSystemOfEquations() {
    let matrix: Matrix = [
      [3, 2, 5, 1],
      [6, 6, 15, 3],
      [-3, 4, 13, 1],
      [-6, 6, 15, 5]
    ]
    let vec: Vector = [1, -6, -17, -52]
    XCTAssertEqual([3, -4, 1, -5], vec !/ matrix)
    XCTAssertEqual(vec, matrix * (vec !/ matrix))
  }
}

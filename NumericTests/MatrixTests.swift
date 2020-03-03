//
//  MatrixTests.swift
//  NumericTests
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import XCTest
@testable import Numeric

class MatrixTests: XCTestCase {
  func testMulitplyWithVector() {
    let matrix: Matrix = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ]
    let vector: Vector = [-2, 5, 1]
    XCTAssertEqual([11, 23, 35], matrix * vector)
  }
}

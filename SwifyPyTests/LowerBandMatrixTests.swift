//
//  LowerBandMatrixTests.swift
//  SwifyPyTests
//
//  Created by Toni Kocjan on 10/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import XCTest
@testable import SwifyPy

class LowerBandMatrixTests: XCTestCase {
  func testDiagonal3x3Subscript() {
    var diagonal: LowerBandMatrix = [[1, 2, 3]]
    XCTAssertEqual(diagonal[0, 0], 1)
    XCTAssertEqual(diagonal[0, 1], 0)
    XCTAssertEqual(diagonal[0, 2], 0)
    XCTAssertEqual(diagonal[1, 0], 0)
    XCTAssertEqual(diagonal[1, 1], 2)
    XCTAssertEqual(diagonal[1, 2], 0)
    XCTAssertEqual(diagonal[0, 2], 0)
    XCTAssertEqual(diagonal[1, 2], 0)
    XCTAssertEqual(diagonal[2, 2], 3)
    diagonal[0, 0] = 10
    diagonal[1, 1] = 20
    diagonal[2, 2] = 30
    XCTAssertEqual(diagonal[0, 0], 10)
    XCTAssertEqual(diagonal[1, 1], 20)
    XCTAssertEqual(diagonal[2, 2], 30)
  }
  
  func testUpperBidiagonal3x3Subscript() {
    var matrix: LowerBandMatrix = [[1, 3, 5], [2, 4]]
    XCTAssertEqual(matrix[0, 0], 1)
    XCTAssertEqual(matrix[0, 1], 0)
    XCTAssertEqual(matrix[0, 2], 0)
    XCTAssertEqual(matrix[1, 0], 2)
    XCTAssertEqual(matrix[1, 1], 3)
    XCTAssertEqual(matrix[1, 2], 0)
    XCTAssertEqual(matrix[2, 0], 0)
    XCTAssertEqual(matrix[2, 1], 4)
    XCTAssertEqual(matrix[2, 2], 5)
    matrix[0, 0] = 10
    matrix[1, 0] = 20
    matrix[1, 1] = 30
    matrix[2, 1] = 40
    matrix[2, 2] = 50
    XCTAssertEqual(matrix[0, 0], 10)
    XCTAssertEqual(matrix[1, 0], 20)
    XCTAssertEqual(matrix[1, 1], 30)
    XCTAssertEqual(matrix[2, 1], 40)
    XCTAssertEqual(matrix[2, 2], 50)
  }
  
  func testUpperBidiagonal4x4Subscript() {
    var matrix: LowerBandMatrix = [[1, 3, 5, 7], [2, 4, 6]]
    XCTAssertEqual(matrix[0, 0], 1)
    XCTAssertEqual(matrix[0, 1], 0)
    XCTAssertEqual(matrix[0, 2], 0)
    XCTAssertEqual(matrix[0, 3], 0)
    XCTAssertEqual(matrix[1, 0], 2)
    XCTAssertEqual(matrix[1, 1], 3)
    XCTAssertEqual(matrix[1, 2], 0)
    XCTAssertEqual(matrix[1, 3], 0)
    XCTAssertEqual(matrix[2, 0], 0)
    XCTAssertEqual(matrix[2, 1], 4)
    XCTAssertEqual(matrix[2, 2], 5)
    XCTAssertEqual(matrix[2, 3], 0)
    XCTAssertEqual(matrix[3, 0], 0)
    XCTAssertEqual(matrix[3, 1], 0)
    XCTAssertEqual(matrix[3, 2], 6)
    XCTAssertEqual(matrix[3, 3], 7)
    matrix[0, 0] = 10
    matrix[1, 0] = 20
    matrix[1, 1] = 30
    matrix[2, 1] = 40
    matrix[2, 2] = 50
    matrix[3, 2] = 60
    matrix[3, 3] = 70
    XCTAssertEqual(matrix[0, 0], 10)
    XCTAssertEqual(matrix[1, 0], 20)
    XCTAssertEqual(matrix[1, 1], 30)
    XCTAssertEqual(matrix[2, 0], 00)
    XCTAssertEqual(matrix[2, 1], 40)
    XCTAssertEqual(matrix[2, 2], 50)
    XCTAssertEqual(matrix[3, 2], 60)
    XCTAssertEqual(matrix[3, 3], 70)
  }
  
  func testIdentity() {
    let matrix = LowerBandMatrix<Double>.identity(4)
    XCTAssertEqual(matrix[0, 0], 1)
    XCTAssertEqual(matrix[0, 1], 0)
    XCTAssertEqual(matrix[0, 2], 0)
    XCTAssertEqual(matrix[0, 3], 0)
    XCTAssertEqual(matrix[1, 0], 0)
    XCTAssertEqual(matrix[1, 1], 1)
    XCTAssertEqual(matrix[1, 2], 0)
    XCTAssertEqual(matrix[1, 3], 0)
    XCTAssertEqual(matrix[2, 0], 0)
    XCTAssertEqual(matrix[2, 1], 0)
    XCTAssertEqual(matrix[2, 2], 1)
    XCTAssertEqual(matrix[2, 3], 0)
    XCTAssertEqual(matrix[3, 0], 0)
    XCTAssertEqual(matrix[3, 1], 0)
    XCTAssertEqual(matrix[3, 2], 0)
    XCTAssertEqual(matrix[3, 3], 1)
  }
  
  func testMulitplyWithVector() {
    let matrix: LowerBandMatrix = [[1, 3, 5, 7], [2, 4, 6]]
    let vector: Vector = [-2, 5, 1, 2]
    XCTAssertEqual([-2, 11, 25,  20], matrix * vector)
    XCTAssertEqual(7, LBM_ITERATIONS_COUNT)
  }
  
  func testIsDiagonalyDominant() {
    XCTAssertTrue(LowerBandMatrix(arrayLiteral: [[1, 1, 1, 1]]).isDiagonalyDominant)
    XCTAssertTrue(LowerBandMatrix(arrayLiteral: [[2, 2, 2, 2], [1, 1, 1]]).isDiagonalyDominant)
    XCTAssertTrue(LowerBandMatrix(arrayLiteral: [[3, 3, 3, 3], [2, 2, 2], [1, 1]]).isDiagonalyDominant)
    XCTAssertFalse(LowerBandMatrix(arrayLiteral: [[1, 1, 1, 1], [2, 2, 2]]).isDiagonalyDominant)
    XCTAssertFalse(LowerBandMatrix(arrayLiteral: [[2, 2, 2, 2], [2, 2, 2], [1, 1]]).isDiagonalyDominant)
  }
  func testCopyOnWrite() {
    let matrix: LowerBandMatrix = [
      [1, 4, 7],
      [2, 5],
      [3]
    ]
    var copy = matrix
    copy[0, 0] = 0
    XCTAssertEqual(0, copy[0, 0])
    XCTAssertEqual(1, matrix[0, 0])
  }
}

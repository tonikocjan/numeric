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
  func testSubscript() {
    let matrix: Matrix = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ]
    XCTAssertEqual([1, 2, 3], matrix[0])
    XCTAssertEqual([4, 5, 6], matrix[1])
    XCTAssertEqual([7, 8, 9], matrix[2])
    XCTAssertEqual(1, matrix[0, 0])
    XCTAssertEqual(2, matrix[0, 1])
    XCTAssertEqual(3, matrix[0, 2])
    XCTAssertEqual(4, matrix[1, 0])
    XCTAssertEqual(5, matrix[1, 1])
    XCTAssertEqual(6, matrix[1, 2])
    XCTAssertEqual(7, matrix[2, 0])
    XCTAssertEqual(8, matrix[2, 1])
    XCTAssertEqual(9, matrix[2, 2])
  }
  
  func testEquatable() {
    XCTAssertEqual(Matrix<Double>(width: 0, height: 0), Matrix(width: 0, height: 0))
    XCTAssertEqual(Matrix<Double>(arrayLiteral: [[1, 2, 3]]), Matrix<Double>(arrayLiteral: [[1, 2, 3]]))
    XCTAssertNotEqual(Matrix<Double>(arrayLiteral: [[1, 2, 3]]), Matrix<Double>(arrayLiteral: [[1, 3, 3]]))
  }
  
  func testArithmetic() {
    let matrix: Matrix = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ]
    XCTAssertEqual([[2, 4, 6],
                    [8, 10, 12],
                    [14, 16, 18]], matrix + matrix)
    XCTAssertEqual([[0, 0, 0],
                    [0, 0, 0],
                    [0, 0, 0]], matrix - matrix)
    XCTAssertEqual([[1, 4, 9],
                    [16, 25, 36],
                    [49, 64, 81]], matrix * matrix)
    XCTAssertEqual([[1, 1, 1],
                    [1, 1, 1],
                    [1, 1, 1]], matrix / matrix)
  }
  
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

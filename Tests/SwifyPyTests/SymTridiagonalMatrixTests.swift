//
//  SymTridiagonalMatrixTests.swift
//  SwifyPyTests
//
//  Created by Toni Kocjan on 25/03/2020.
//

import XCTest
@testable import SwifyPy

class SymTridiagonalMatrixTests: XCTestCase {
  func test3x3DiagonalSubscript() {
    var matrix: SymTridiagonalMatrix = [[1, 2, 3]]
    XCTAssertEqual(1, matrix[0, 0])
    XCTAssertEqual(2, matrix[1, 1])
    XCTAssertEqual(3, matrix[2, 2])
    XCTAssertEqual(0, matrix[0, 1])
    XCTAssertEqual(0, matrix[0, 2])
    XCTAssertEqual(0, matrix[1, 0])
    XCTAssertEqual(0, matrix[1, 2])
    XCTAssertEqual(0, matrix[2, 0])
    XCTAssertEqual(0, matrix[2, 1])
    matrix[0, 0] = 100
    matrix[1, 1] = 100
    matrix[2, 2] = 100
    XCTAssertEqual(100, matrix[0, 0])
    XCTAssertEqual(100, matrix[1, 1])
    XCTAssertEqual(100, matrix[2, 2])
  }
  
  func test3x3Tridiagonal() {
    var matrix: SymTridiagonalMatrix = [[1, 3, 5], [2, 4]]
    XCTAssertEqual(1, matrix[0, 0])
    XCTAssertEqual(2, matrix[0, 1])
    XCTAssertEqual(0, matrix[0, 2])
    XCTAssertEqual(2, matrix[1, 0])
    XCTAssertEqual(3, matrix[1, 1])
    XCTAssertEqual(4, matrix[1, 2])
    XCTAssertEqual(0, matrix[2, 0])
    XCTAssertEqual(4, matrix[2, 1])
    XCTAssertEqual(5, matrix[2, 2])
    matrix[0, 1] = 100
    XCTAssertEqual(100, matrix[0, 1])
    XCTAssertEqual(100, matrix[1, 0])
  }
  
  func testIdentity() {
    let id = SymTridiagonalMatrix<Double>.identity(4)
    for i in 0..<id.width {
      for j in 0..<id.width {
        XCTAssertEqual(i == j ? 1 : 0, id[i, j])
      }
    }
  }
}

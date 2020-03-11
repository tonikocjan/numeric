//
//  BandMatrixTests.swift
//  SwifyPyTests
//
//  Created by Toni Kocjan on 10/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import XCTest
@testable import SwifyPy

class BandMatrixTests: XCTestCase {
  func testDiagonal3x3Subscript() {
    var diagonal: BandMatrix = [[1], [2], [3]]
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
  
  func testTridiagonal3x3Subscript() {
    var matrix: BandMatrix = [[1, 2], [3, 4, 5], [6, 7]]
    XCTAssertEqual(matrix[0, 0], 1)
    XCTAssertEqual(matrix[0, 1], 2)
    XCTAssertEqual(matrix[0, 2], 0)
    XCTAssertEqual(matrix[1, 0], 3)
    XCTAssertEqual(matrix[1, 1], 4)
    XCTAssertEqual(matrix[1, 2], 5)
    XCTAssertEqual(matrix[2, 0], 0)
    XCTAssertEqual(matrix[2, 1], 6)
    XCTAssertEqual(matrix[2, 2], 7)
    matrix[0, 0] = 10
    matrix[0, 1] = 20
    matrix[1, 0] = 30
    matrix[1, 1] = 40
    matrix[1, 2] = 50
    matrix[2, 1] = 60
    matrix[2, 2] = 70
    XCTAssertEqual(matrix[0, 0], 10)
    XCTAssertEqual(matrix[0, 1], 20)
    XCTAssertEqual(matrix[1, 0], 30)
    XCTAssertEqual(matrix[1, 1], 40)
    XCTAssertEqual(matrix[1, 2], 50)
    XCTAssertEqual(matrix[2, 1], 60)
    XCTAssertEqual(matrix[2, 2], 70)
  }
  
  func testTridiagonal4x4Subscript() {
    var matrix: BandMatrix = [
      [1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [9, 10]
    ]
    XCTAssertEqual(matrix[0, 0], 1)
    XCTAssertEqual(matrix[0, 1], 2)
    XCTAssertEqual(matrix[0, 2], 0)
    XCTAssertEqual(matrix[0, 3], 0)
    XCTAssertEqual(matrix[1, 0], 3)
    XCTAssertEqual(matrix[1, 1], 4)
    XCTAssertEqual(matrix[1, 2], 5)
    XCTAssertEqual(matrix[1, 3], 0)
    XCTAssertEqual(matrix[2, 0], 0)
    XCTAssertEqual(matrix[2, 1], 6)
    XCTAssertEqual(matrix[2, 2], 7)
    XCTAssertEqual(matrix[2, 3], 8)
    XCTAssertEqual(matrix[3, 0], 0)
    XCTAssertEqual(matrix[3, 1], 0)
    XCTAssertEqual(matrix[3, 2], 9)
    XCTAssertEqual(matrix[3, 3], 10)
    matrix[0, 0] = 10
    matrix[0, 1] = 20
    matrix[1, 0] = 30
    matrix[1, 1] = 40
    matrix[1, 2] = 50
    matrix[2, 1] = 60
    matrix[2, 2] = 70
    matrix[2, 3] = 80
    matrix[3, 2] = 90
    matrix[3, 3] = 100
    XCTAssertEqual(matrix[0, 0], 10)
    XCTAssertEqual(matrix[0, 1], 20)
    XCTAssertEqual(matrix[1, 0], 30)
    XCTAssertEqual(matrix[1, 1], 40)
    XCTAssertEqual(matrix[1, 2], 50)
    XCTAssertEqual(matrix[2, 1], 60)
    XCTAssertEqual(matrix[2, 2], 70)
    XCTAssertEqual(matrix[2, 3], 80)
    XCTAssertEqual(matrix[3, 2], 90)
    XCTAssertEqual(matrix[3, 3], 100)
  }
  
  func testPentaDiagonal4x4() {
    let band: BandMatrix = [
      [3, 2, 5],
      [6, 6, 15, 3],
      [-3, 4, 13, 1],
      [-6, 6, 15]
    ]
    let mat: Matrix = [
      [3, 2, 5, 0],
      [6, 6, 15, 3],
      [-3, 4, 13, 1],
      [0, -6, 6, 15]
    ]
    XCTAssertTrue(band == mat)
  }
  
  func testPentaDiagonal5x5() {
    let band: BandMatrix = [
      [3, 2, 5],
      [6, 6, 15, 3],
      [-3, 4, 13, 1, 10],
      [-6, 6, 15, -5],
      [1, 1, 1]
    ]
    let mat: Matrix = [
      [3, 2, 5, 0, 0],
      [6, 6, 15, 3, 0],
      [-3, 4, 13, 1, 10],
      [0, -6, 6, 15, -5],
      [0, 0, 1, 1, 1]
    ]
    XCTAssertTrue(band == mat)
  }
  
  func testIdentity() {
    let matrix = BandMatrix<Double>.identity(4)
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
    let matrix: BandMatrix = [
      [1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [9, 10]
    ]
    let vector: Vector = [-2, 5, 1, 2]
    XCTAssertEqual([8, 19, 53, 29], matrix * vector)
    XCTAssertEqual(10, BM_ITERATIONS_COUNT)
  }
  
  func testCopyOnWrite() {
    let matrix: BandMatrix = [
      [1, 4],
      [2, 5, 8],
      [3, 6]
    ]
    var copy = matrix
    copy[0, 0] = 0
    XCTAssertEqual(0, copy[0, 0])
    XCTAssertEqual(1, matrix[0, 0])
  }
}

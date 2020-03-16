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
//    diagonal[0] = [100]
//    diagonal[1] = [200]
//    diagonal[2] = [300]
//    XCTAssertEqual(diagonal[0, 0], 100)
//    XCTAssertEqual(diagonal[1, 1], 200)
//    XCTAssertEqual(diagonal[2, 2], 300)
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
    XCTAssertEqual(5, band.bandwidth)
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
  
  func testIsDiagonalyDominant() {
    XCTAssertTrue(BandMatrix(arrayLiteral: [1], [1], [1], [1]).isDiagonalyDominant)
    XCTAssertTrue(BandMatrix(arrayLiteral: [2, 1], [1, 2, 1], [1, 2, 1], [1, 1]).isDiagonalyDominant)
    XCTAssertFalse(BandMatrix(arrayLiteral: [2, 3], [1, 2, 1], [1, 2, 1], [2, 1]).isDiagonalyDominant)
    XCTAssertFalse(BandMatrix(arrayLiteral: [2, 1], [1, 2, 2], [1, 2, 1], [2, 1]).isDiagonalyDominant)
    XCTAssertFalse(BandMatrix(arrayLiteral: [2, 1], [1, 2, 1], [1, 2, 1], [2, 1]).isDiagonalyDominant)
    XCTAssertFalse(BandMatrix(arrayLiteral: [2, 1], [1, 2, 1], [1, 2, 2], [2, 1]).isDiagonalyDominant)
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

// MARK: - LUDecomposition tests
extension BandMatrixTests {
  func testDiagonal3x3Decomposition() {
    let band: BandMatrix = [
      [3],
      [-4],
      [13],
    ]
    let (L, U) = LUDecomposition(band)
    XCTAssertEqual([[1, 1, 1]], L)
    XCTAssertEqual([[3, -4, 13]], U)
  }
  
  func testTridiagonal4x4Decomposition() {
    let band: BandMatrix = [
      [3, 2],
      [-4, 7, 8],
      [4, 13, 1],
      [5, 15]
    ]
    let (L, U) = LUDecomposition(band)
    XCTAssertEqual([[1, 1, 1, 1],
                    [-4.0 / 3, 4 / 9.6667, 5 / 9.6897]], L, accuracy: 10e-4)
    XCTAssertEqual([[3, 9.6667, 9.6897, 14.484],
                    [2, 8, 1]], U, accuracy: 10e-4)
  }
  
  func testPentaDiagonal6x6Decomposition() {
    let band: BandMatrix = [
      [4, 2, 1],
      [4, 12, 7, 1],
      [-5, 1, 10, 1, 1],
      [-1, 1, 8, 2, 3],
      [1, 4, 6, -1],
      [4, 5, 10]
    ]
    let (L, U) = LUDecomposition(band)
    XCTAssertEqual([[1, 1, 1, 1, 1, 1],
                    [1, 0.35, 0.1749, 0.492, 0.8184],
                    [-1.25, -0.1, 0.1093, 0.5009]], L, accuracy: 10e-4)
    XCTAssertEqual([[4, 10, 9.15, 7.9863, 4.9928, 10.5236],
                    [2, 6, 0.65, 1.8251, -2.4759],
                    [1, 1, 1, 3]], U, accuracy: 10e-4)
  }
}

// MARK: - Linear Equations tests
extension BandMatrixTests {
  func testLinearEquations1() {
    let A: BandMatrix = [
      [3, 2],
      [-4, 7, 8],
      [4, 13, 1],
      [5, 15]
    ]
    let y: Vector = [1, 2, 3, 4]
    let x = y !/ A
    XCTAssertEqual([0.1833, 0.2251, 0.1447, 0.2184], x, accuracy: 10e-4)
    XCTAssertEqual(A * x, y, accuracy: 10e-4)
  }
}

// MARK: - Helper functions
func XCTAssertEqual<T: Mathable>(_ lhs: LowerBandMatrix<T>, _ rhs: LowerBandMatrix<T>, accuracy: T) {
  for i in 0..<lhs.width {
    for j in 0..<lhs.width {
      if abs(lhs[i, j] - rhs[i, j]) > accuracy {
        XCTFail("\(lhs[i, j]) is not equal to \(rhs[i, j])")
        return
      }
    }
  }
}

func XCTAssertEqual<T: Mathable>(_ lhs: UpperBandMatrix<T>, _ rhs: UpperBandMatrix<T>, accuracy: T) {
  for i in 0..<lhs.width {
    for j in 0..<lhs.width {
      if abs(lhs[i, j] - rhs[i, j]) > accuracy {
        XCTFail("\(lhs[i, j]) is not equal to \(rhs[i, j])")
        return
      }
    }
  }
}

func XCTAssertEqual<T: Mathable>(_ lhs: Vector<T>, _ rhs: Vector<T>, accuracy: T) {
  for i in 0..<lhs.count {
    if abs(lhs[i] - rhs[i]) > accuracy {
      XCTFail("\(lhs[i]) is not equal to \(rhs[i]) at index \(i)")
      return
    }
  }
}

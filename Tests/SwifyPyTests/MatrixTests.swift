//
//  MatrixTests.swift
//  SwifyPyTests
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import XCTest
@testable import SwifyPy

class MatrixTests: XCTestCase {
  func testSubscript() {
    var matrix: Matrix = [
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
    
    matrix[0, 0] = 10
    XCTAssertEqual(10, matrix[0, 0])
    XCTAssertEqual([10, 2, 3], matrix[0])
    XCTAssertEqual([4, 5, 6], matrix[1])
    XCTAssertEqual([7, 8, 9], matrix[2])
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
    XCTAssertEqual([[3, 4, 5],
                    [6, 7, 8],
                    [9, 10, 11]], matrix + 2.0)
    XCTAssertEqual([[-1, 0, 1],
                    [2, 3, 4],
                    [5, 6, 7]], matrix - 2.0)
    XCTAssertEqual([[2, 4, 6],
                    [8, 10, 12],
                    [14, 16, 18]], matrix * 2.0)
    XCTAssertEqual([[1.0/2, 1, 3.0/2],
                    [2, 5.0/2, 3],
                    [7.0/2, 4, 9.0/2]], matrix / 2.0)
    XCTAssertEqual([[3, 4, 5],
                    [6, 7, 8],
                    [9, 10, 11]], 2.0 + matrix)
    XCTAssertEqual([[-1, 0, 1],
                    [2, 3, 4],
                    [5, 6, 7]], 2.0 - matrix)
    XCTAssertEqual([[2, 4, 6],
                    [8, 10, 12],
                    [14, 16, 18]], 2.0 * matrix)
    XCTAssertEqual([[1.0/2, 1, 3.0/2],
                    [2, 5.0/2, 3],
                    [7.0/2, 4, 9.0/2]], 2.0 / matrix)
    
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
  
  func testMatrixMultiplication() {
    let m1: Matrix = [
      [1, 2, 3],
      [4, 5, 6]
    ]
    let m2: Matrix = [
      [7, 8],
      [9, 10],
      [11, 12]
    ]
    XCTAssertEqual([[58, 64], [139, 154]], m1 * m2)
    
    let m3: Matrix = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ]
    XCTAssertEqual(m3, m3 * Matrix.identity(3))
    XCTAssertEqual(m3, Matrix.identity(3) * m3)
  }
  
  func testIdentity() {
    XCTAssertEqual([[1, 0], [0, 1]], Matrix<Double>.identity(2))
    XCTAssertEqual([[1, 0, 0], [0, 1, 0], [0, 0, 1]], Matrix<Double>.identity(3))
  }
  
  func testReduce() {
    let matrix: Matrix = [
      [1, 4, 7],
      [2, 5, 8],
      [3, 6, 9]
    ]
    XCTAssertEqual([12, 15, 18], matrix.reduce([], { $0 + [$1.sum]}))
  }
  
  func testColumnMap() {
    let matrix: Matrix = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ]
    XCTAssertEqual(matrix.transposed, Matrix(arrayLiteral: matrix.columnMap { $0 }))
  }
  
  func testColumnFilter() {
    let matrix: Matrix = [
      [1, 2, 3],
      [1, 2, 3],
      [1, 2, 3]
    ]
    let filtered: Matrix<Double> = matrix.columnFilter { $0.contains(where: { $0.truncatingRemainder(dividingBy: 2) == 0 }) }
    XCTAssertEqual([[2, 2, 2]], filtered)
  }
  
  func testColumnReduce() {
    let matrix: Matrix = [
      [1, 4, 7],
      [2, 5, 8],
      [3, 6, 9]
    ]
    XCTAssertEqual([6, 15, 24], matrix.columnReduce([], nextPartialResult: { $0 + [$1.sum]}))
  }
  
  func testTransposed() {
    let matrix: Matrix = [
      [1, 4, 7],
      [2, 5, 8],
      [3, 6, 9]
    ]
    XCTAssertEqual([[1, 2, 3],
                    [4, 5, 6],
                    [7, 8, 9]], matrix.transposed)
  }
  
  func testZeros() {
    let matrix: Matrix<Double> = .zeros(width: 3, height: 3)
    XCTAssertEqual([0, 0, 0], matrix[0])
    XCTAssertEqual([0, 0, 0], matrix[1])
    XCTAssertEqual([0, 0, 0], matrix[2])
  }
  
  func testOnes() {
    let matrix: Matrix<Double> = .ones(width: 3, height: 3)
    XCTAssertEqual([1, 1, 1], matrix[0])
    XCTAssertEqual([1, 1, 1], matrix[1])
    XCTAssertEqual([1, 1, 1], matrix[2])
  }
  
  func testCopyOnWrite() {
    let matrix: Matrix = [
      [1, 4, 7],
      [2, 5, 8],
      [3, 6, 9]
    ]
    var copy = matrix
    copy[0, 0] = 0
    XCTAssertEqual(0, copy[0, 0])
    XCTAssertEqual(1, matrix[0, 0])
  }
}

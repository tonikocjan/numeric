//
//  QRDecompositionTests.swift
//  SwifyPyTests
//
//  Created by Toni Kocjan on 25/03/2020.
//

import XCTest
@testable import SwifyPy

class QRDecompositionTests: XCTestCase {
  func test3x3() {
    let A: Matrix = [
      [12, -51, 4],
      [6, 167, -68],
      [-4, 24, -41]
    ]
    let (Q, R) = QRDecomposition(A)
    XCTAssertEqual(A, Q * R, accuracy: 10e-6)
    XCTAssertTrue(R.isUpperTriangular)
  }
  
  func test4x4() {
    let A: Matrix = [
      [12, -51, 4, 8],
      [6, 167, -13,  -68],
      [-4, 24, 6, -41],
      [1, 2, 3, 4]
    ]
    let (Q, R) = QRDecomposition(A)
    XCTAssertEqual(A, Q * R, accuracy: 10e-6)
    XCTAssertTrue(R.isUpperTriangular)
  }
  
  func test5x5() {
    let A: Matrix = [
      [12, -51, 4, 0, 8],
      [6, 167, 12, -13,  -68],
      [100, -4, 24, 6, -41],
      [1, 2, 3, 4, 5],
      [-8, 8, -8,  8, 1]
    ]
    let (Q, R) = QRDecomposition(A)
    XCTAssertEqual(A, Q * R, accuracy: 10e-6)
    XCTAssertTrue(R.isUpperTriangular)
  }
  
  func testSymTridiagonal3x3() {
    let A: SymTridiagonalMatrix = [[1, 3, 5], [2, 4]]
    let (Q, R) = QRDecomposition(A)
    XCTAssertEqual(A, Q * R, accuracy: 10e-6)
    XCTAssertTrue(R.isUpperTriangular)
  }
  
  func testSymTridiagonal4x4() {
    let A: SymTridiagonalMatrix = [[1, 3, 5, 7], [2, 4, 6]]
    let (Q, R) = QRDecomposition(A)
    XCTAssertEqual(A, Q * R, accuracy: 10e-6)
    XCTAssertTrue(R.isUpperTriangular)
  }
}

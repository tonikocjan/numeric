//
//  Laplace2DTests.swift
//  SwifyPyTests
//
//  Created by Toni Kocjan on 17/03/2020.
//

import XCTest
@testable import SwifyPy

class Laplace2DTests: XCTestCase {
  func testCoefficientsMatrix3x3() {
    let m: BandMatrix<Double> = Laplace2D.coefficientsMatrix(n: 3, m: 3)
    let expected: Matrix<Double> = [
      [-4.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      [1.0, -4.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0],
      [0.0, 1.0, -4.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0],
      [1.0, 0.0, 0.0, -4.0, 1.0, 0.0, 1.0, 0.0, 0.0],
      [0.0, 1.0, 0.0, 1.0, -4.0, 1.0, 0.0, 1.0, 0.0],
      [0.0, 0.0, 1.0, 0.0, 1.0, -4.0, 0.0, 0.0, 1.0],
      [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, -4.0, 1.0, 0.0],
      [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, -4.0, 1.0],
      [0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, -4.0]
    ]
    XCTAssertTrue(expected == m)
  }
  
  func testRightHandSide3x3() {
    let v: Vector<Double> = Laplace2D.rightHandSides(s: [1, 2, 3],
                                                     d: [1, 2, 3],
                                                     z: [1, 2, 3],
                                                     l: [1, 2, 3])
    XCTAssertEqual([-2.0, -2.0, -4.0, -2.0, -0.0, -2.0, -4.0, -2.0, -6.0], v)
  }
  
  func testSolveBoundaryProblem() {
    let (Z, x, y) = Laplace2D.solveBoundaryProblem(fs: sin,
                                                   fd: { -sin($0) },
                                                   fz: sin,
                                                   fl: { -sin($0) },
                                                   h: 1,
                                                   bounds: ((0, 3), (0, 3)))
    XCTAssertEqual([0.0, 1.0, 2.0, 3.0], x)
    XCTAssertEqual([0.0, 1.0, 2.0, 3.0], y)
    XCTAssertEqual([[0.0, 0.8414709848078965, 0.9092974268256817, 0.1411200080598672],
                    [-0.8414709848078965, -0.2916666666666667, -0.06637672282888703, -0.8414709848078965],
                    [-0.9092974268256817, -0.10028994383777964, -0.041666666666666664, -0.9092974268256817],
                    [0.0, 0.8414709848078965, 0.9092974268256817, 0.1411200080598672]], Z)
  }
}

//
//  VectorTests.swift
//  NumericTests
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import XCTest
@testable import SwifyPy

class VectorTests: XCTestCase {
  func testSubscript() {
    let vector = Vector<Double>(arrayLiteral: [1, 2, 3])
    XCTAssertEqual(1, vector[0])
    XCTAssertEqual(2, vector[1])
    XCTAssertEqual(3, vector[2])
  }
  
  func testIsEmpty() {
    XCTAssertTrue(Vector<Double>(size: 0).isEmpty)
    XCTAssertFalse(Vector<Double>(size: 2).isEmpty)
  }
  
  func testCollection() {
    let vector = Vector<Double>(arrayLiteral: [1, 2, 3])
    XCTAssertEqual(6, vector.reduce(0, +))
    XCTAssertEqual([2, 4, 6], vector.map { $0 * 2 })
    XCTAssertEqual([2], vector.filter { $0.truncatingRemainder(dividingBy: 2) == 0 })
    XCTAssertEqual(1, vector.first)
    XCTAssertEqual(3, vector.last)
  }
  
  func testEquatable() {
    XCTAssertEqual(Vector<Double>(), Vector<Double>())
    XCTAssertNotEqual(Vector<Double>(), Vector<Double>(size: 1))
    XCTAssertEqual(Vector<Double>(arrayLiteral: [1, 2, 3]), Vector<Double>(arrayLiteral: [1, 2, 3]))
    XCTAssertNotEqual(Vector<Double>(arrayLiteral: [1, 2, 3]), Vector<Double>(arrayLiteral: [1, 3, 3]))
  }
  
  func testArithmetic() {
    let v1 = Vector<Double>(arrayLiteral: [2, 4, 6])
    let v2 = Vector<Double>(arrayLiteral: [1, 3, 5])
    XCTAssertEqual([3, 7, 11], v1 + v2)
    XCTAssertEqual([1, 1, 1], v1 - v2)
    XCTAssertEqual([2, 12, 30], v1 * v2)
    XCTAssertEqual([2, 4.0 / 3, 6.0 / 5], v1 / v2)
    XCTAssertEqual(44, v1.dot(v2))
    XCTAssertEqual([3, 5, 7], v1 + 1)
    XCTAssertEqual([1, 3, 5], v1 - 1)
    XCTAssertEqual([4, 8, 12], v1 * 2)
    XCTAssertEqual([1, 2, 3], v1 / 2)
    XCTAssertEqual([3, 5, 7], 1 + v1)
    XCTAssertEqual([-1, -3, -5], 1 - v1)
    XCTAssertEqual([4, 8, 12], 2 * v1)
    XCTAssertEqual([1, 0.5, 1.0/3], 2 / v1)
  }
  
  func testComputedProperties() {
    let v1 = Vector<Double>(arrayLiteral: [2, 4, 6])
    XCTAssertEqual(4, v1.avg)
    XCTAssertEqual(12, v1.sum)
    XCTAssertEqual(sqrt(56), v1.len)
  }
  
  func testSqrt() {
    XCTAssertEqual([1, 2, 3, 4, 5], sqrt(Vector(arrayLiteral: [1, 4, 9, 16, 25])))
  }
  
  func testCopyOnWrite() {
    let v: Vector = [1, 2, 3]
    var copy = v
    copy[0] = 0
    XCTAssertEqual(0, copy[0])
    XCTAssertEqual(1, v[0])
  }
}

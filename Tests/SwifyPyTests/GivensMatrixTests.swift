//
//  GivensMatrixTests.swift
//  SwifyPyTests
//
//  Created by Toni Kocjan on 31/03/2020.
//

import XCTest
@testable import SwifyPy

class GivensMatrixTests: XCTestCase {
  func testSubscript() {
    let i = 1
    let j = 0
    let c = Float(10)
    let s = Float(11)
    let givens = GivensMatrix(i: i, j: j, c: c, s: s, size: 4)
    for k in 0..<4 {
      for l in 0..<4 {
        if k == l {
          if k == i || l == j {
            XCTAssertEqual(c, givens[k, l])
            continue
          }
          XCTAssertEqual(1, givens[k, l])
          continue
        }
        if k == i && l == j {
          XCTAssertEqual(-s, givens[k, l])
          continue
        }
        if k == j && l == i {
          XCTAssertEqual(s, givens[k, l])
          continue
        }
        XCTAssertEqual(0, givens[k, l])
      }
    }
  }
}

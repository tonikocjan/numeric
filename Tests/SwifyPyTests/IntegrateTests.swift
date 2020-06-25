//
//  IntegrateTests.swift
//  SwifyPyTests
//
//  Created by Toni Kocjan on 06/04/2020.
//

import XCTest
@testable import SwifyPy

class IntegrateTests: XCTestCase {
  let f1 = Function<Double, Double> { sqrt($0 - 2) } // f1(x) = √(x - 2)
  let s1 = 14.0 / 3 // ∫f1 dx from 3 to 6
  let s2 = 646.100335858628802318638976538 // ∫f1 dx from 3 to 100
  
  let f2 = Function<Double, Double> { $0 } // f2(x) = x
  let f3 = Function<Double, Double> { $0 * $0 } // f3(x) = x²
  
  func testTrapezoidial() {
    let steps = [1, 2, 5, 10, 100, 1000]
      .map { f1.integrate(on: (3, 6), n: $0, method: .trapezoidial) }
      .map { abs($0 - 14.0 / 3.0) }
    steps
      .enumerated()
      .forEach { XCTAssertLessThan(pow(10, -Double($0.offset + 1 )), abs(s1 - $0.element)) }
    
    XCTAssertEqual(0.5, f2.integrate(on: (0, 1), n: 1, method: .trapezoidial))
    XCTAssertEqual(2, f2.integrate(on: (0, 2), n: 1, method: .trapezoidial))
    XCTAssertEqual(4.5, f2.integrate(on: (0, 3), n: 1, method: .trapezoidial))
    XCTAssertEqual(50, f2.integrate(on: (0, 10), n: 1, method: .trapezoidial))
    
    XCTAssertGreaterThan(10e-4, abs((1.0 / 3) - f3.integrate(on: (0, 1), n: 100, method: .trapezoidial)))
    XCTAssertGreaterThan(10e-4, abs((8.0 / 3) - f3.integrate(on: (0, 2), n: 100, method: .trapezoidial)))
    XCTAssertGreaterThan(10e-4, abs((27.0 / 3) - f3.integrate(on: (0, 3), n: 100, method: .trapezoidial)))
    XCTAssertGreaterThan(10e-4, abs((1000.0 / 3) - f3.integrate(on: (0, 10), n: 1000, method: .trapezoidial)))
  }
  
  func testSimpson() {
    XCTAssertGreaterThan(10e-7, abs(s1 - f1.integrate(on: (3, 6), n: 10, method: .simspon)))
    XCTAssertGreaterThan(10e-10, abs(s1 - f1.integrate(on: (3, 6), n: 100, method: .simspon)))
    XCTAssertGreaterThan(10e-15, abs(s1 - f1.integrate(on: (3, 6), n: 1000, method: .simspon)))
    
    XCTAssertEqual(0.5, f2.integrate(on: (0, 1), n: 1, method: .simspon))
    XCTAssertEqual(2, f2.integrate(on: (0, 2), n: 1, method: .simspon))
    XCTAssertEqual(4.5, f2.integrate(on: (0, 3), n: 1, method: .simspon))
    XCTAssertEqual(50, f2.integrate(on: (0, 10), n: 1, method: .simspon))
    
    XCTAssertGreaterThan(10e-15, abs((1.0 / 3) - f3.integrate(on: (0, 1), n: 1, method: .simspon)))
    XCTAssertGreaterThan(10e-15, abs((8.0 / 3) - f3.integrate(on: (0, 2), n: 1, method: .simspon)))
    XCTAssertGreaterThan(10e-15, abs((27.0 / 3) - f3.integrate(on: (0, 3), n: 1, method: .simspon)))
    XCTAssertGreaterThan(10e-13, abs((1000.0 / 3) - f3.integrate(on: (0, 10), n: 1, method: .simspon)))
  }
  
  func testRomberg() {
    XCTAssertGreaterThan(10e-10, abs(s1 - f1.integrate(on: (3, 6), n: 5)))
    XCTAssertGreaterThan(10e-20, abs(s1 - f1.integrate(on: (3, 6), n: 10)))
    XCTAssertGreaterThan(10e-10, abs(s2 - f1.integrate(on: (3, 100), n: 10)))
    
    XCTAssertEqual(0.5, f2.integrate(on: (0, 1), n: 1, method: .romberg))
    XCTAssertEqual(2, f2.integrate(on: (0, 2), n: 1, method: .romberg))
    XCTAssertEqual(4.5, f2.integrate(on: (0, 3), n: 1, method: .romberg))
    XCTAssertEqual(50, f2.integrate(on: (0, 10), n: 1, method: .romberg))
    
    XCTAssertGreaterThan(10e-15, abs((1.0 / 3) - f3.integrate(on: (0, 1), n: 2, method: .romberg)))
    XCTAssertGreaterThan(10e-15, abs((8.0 / 3) - f3.integrate(on: (0, 2), n: 2, method: .romberg)))
    XCTAssertGreaterThan(10e-15, abs((27.0 / 3) - f3.integrate(on: (0, 3), n: 2, method: .romberg)))
    XCTAssertGreaterThan(10e-13, abs((1000.0 / 3) - f3.integrate(on: (0, 10), n: 2, method: .romberg)))
  }
}

// MARK: - Sinc tests
extension IntegrateTests {
  var sineIntegralSolutions: [(Double, Double)] {
    [
      (            1, 0.9460830703),
      (            2, 1.6054129768),
      (            3, 1.8486525279),
      (            4, 1.7582031389),
      (            5, 1.5499312449),
      (            6, 1.4246875512),
      (            7, 1.4545966142),
      (            8, 1.5741868217),
      (            9, 1.6650400758),
      (           10, 1.6583475942),
      (           15, 1.6181944437),
      (           20, 1.5482417010),
      (           30, 1.5667565400),
      (           50, 1.5516170724),
      (          100, 1.5622254668),
      (         1000, 1.5702331219),
      (      100_000, 1.5708063203),
      (    1_000_000, 1.5707953900),
      (1_000_000_000, 1.5707963259)
    ]
  }
  
  func testSincTaylorExpansion() {
    let actual = [10.0, -55.55555555555556, 166.66666666666666, -283.4467120181406, 306.1924358220655, -227.746439867652, 123.53110643708935, -50.981091545465446, 16.537983849091297, -4.326650129802279]
    XCTAssertEqual(actual, taylorExpansionIterator(10).prefix(10).map { $0 })
  }
  
  func testSincTaylorSeries() {
    let N = [10,10,10,15,15,15,15,20,20,20,30,35]
    for ((x, Six), n) in zip(sineIntegralSolutions, N) {
      let a = taylorExpansionSineIntegral(x, n: n)
      XCTAssertGreaterThan(10e-10, abs(a - Six))
    }
  }
  
  func testSincRomberg() {
    let N = [6, 9, 10, 10, 10, 10, 13, 19]
    for ((x, Six), n) in zip(sineIntegralSolutions.dropFirst(9), N) {
      let a = sineIntegral(x: x, method: romberg, k: n)
      XCTAssertGreaterThan(10e-10, abs(a - Six))
    }
  }
}

//
//  MatrixProtocol.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 10/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

public typealias Mathable = FloatingPoint

public protocol MatrixProtocol: ExpressibleByArrayLiteral, Equatable, BidirectionalCollection where Element == Vector {
  associatedtype Value: Mathable
  typealias Vector = SwifyPy.Vector<Value>
  
  var width: Int { get }
  var height: Int { get }
  
  init(arrayLiteral elements: [Vector])
  init(arrayLiteral elements: Vector...)
  
  subscript(_ i: Int, _ j: Int) -> Value { get mutating set }
  subscript(_ i: Int) -> Vector { get mutating set }
  
  static func identity(_ size: Int) -> Self
}

public extension MatrixProtocol {
  func index(after i: Int) -> Int { i + 1 }
  func index(before i: Int) -> Int { i - 1 }
  var startIndex: Int { 0 }
  var endIndex: Int { height }
  var shape: (width: Int, height: Int) { (width, height) }
  var firstIndex: (Int, Int)? { isEmpty ? nil : (0, 0) }
  var lastIndex: (Int, Int)? { isEmpty ? nil : (height - 1, width - 1) }
  
  func map(_ transform: (Vector) throws -> Vector) rethrows -> Self {
    .init(arrayLiteral: try map(transform))
  }
}

public func == <M1: MatrixProtocol, M2: MatrixProtocol>(_ lhs: M1, _ rhs: M2) -> Bool where M1.Value == M2.Value {
  guard lhs.shape == rhs.shape else { return false }
  return zip(lhs, rhs).allSatisfy(==)
}

/// Math

public func +<M: MatrixProtocol>(_ m: M, _ val: M.Value) -> M {
  m.map { $0 + val }
}

public func -<M: MatrixProtocol>(_ m: M, _ val: M.Value) -> M {
  m.map { $0 - val }
}

public func *<M: MatrixProtocol>(_ m: M, _ val: M.Value) -> M {
  m.map { $0 * val }
}

public func /<M: MatrixProtocol>(_ m: M, _ val: M.Value) -> M {
  m.map { $0 / val }
}

public func +<M: MatrixProtocol>(_ val: M.Value, _ m: M) -> M {
  m.map { $0 + val }
}

public func -<M: MatrixProtocol>(_ val: M.Value, _ m: M) -> M {
  m.map { $0 - val }
}

public func *<M: MatrixProtocol>(_ val: M.Value, _ m: M) -> M {
  m.map { $0 * val }
}

public func /<M: MatrixProtocol>(_ val: M.Value, _ m: M) -> M {
  m.map { $0 / val }
}

public func +<M: MatrixProtocol>(_ m1: M, _ m2: M) -> M {
  assert(m1.height == m2.height)
  assert(m1.width == m2.width)
  return zip(m1, m2).map { $0 + $1 }
}

public func -<M: MatrixProtocol>(_ m1: M, _ m2: M) -> M {
  assert(m1.height == m2.height)
  assert(m1.width == m2.width)
  return zip(m1, m2).map { $0 - $1 }
}

public func *<M: MatrixProtocol>(_ m: M, _ v: M.Vector) -> M.Vector {
  assert(m.height == v.count)
  return m.map { ($0 * v).sum }
}

public func *<M: MatrixProtocol & Transposable>(_ m1: M, _ m2: M) -> Matrix<M.Value> {
  // multiplication implemented functionaly
  assert(m1.width == m2.height)
  assert(m1.height == m2.width)
  return m1.map { v1 in
    Vector(arrayLiteral: m2.columnMap { v1.dot($0) })
  }
}

public func *<M: MatrixProtocol>(_ m1: M, _ m2: M) -> Matrix<M.Value> {
  // multiplication implemented proceduraly
  assert(m1.width == m2.height)
  assert(m1.height == m2.width)
  var res = Matrix<M.Value>(width: m2.width, height: m1.height)
  for i in 0..<res.height {
    let row = m1[i]
    for j in 0..<m2.width {
      var sum = M.Value.zero
      for k in 0..<m2.height {
        sum += m2[k, j] * row[k]
      }
      res[i, j] = sum
    }
  }
  return res
}

infix operator !/: MultiplicationPrecedence
public func !/<M: MatrixProtocol>(_ v: M.Vector, _ m: M) -> M.Vector {
  // solve linear system of equations
  solveLinearSystem(LUDecomposition(m), v)
}

extension Zip2Sequence where Sequence1: MatrixProtocol, Sequence2: MatrixProtocol, Sequence1.Value == Sequence2.Value {
  public typealias Matrix = Sequence1
  public typealias Vec = Matrix.Vector
  
  public func map(_ transform: ((Vec, Vec)) throws -> Vec) rethrows -> Matrix {
    Matrix(arrayLiteral: try map(transform))
  }
}

extension Collection {
  public func map<T: Mathable>(_ transform: (Element) throws -> Vector<T>) rethrows -> Matrix<T> {
    Matrix(arrayLiteral: try map(transform))
  }
}

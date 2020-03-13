//
//  MatrixProtocol.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 10/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

typealias Mathable = FloatingPoint

protocol MatrixProtocol: ExpressibleByArrayLiteral, Equatable, BidirectionalCollection where Element == Vec {
  associatedtype Value: Mathable
  // is there a way to shadow `Vector`?
  typealias Vec = Vector<Value>
  
  var width: Int { get }
  var height: Int { get }
  
  init(arrayLiteral elements: [Vector<Value>])
  init(arrayLiteral elements: Vector<Value>...)
  
  subscript(_ i: Int, _ j: Int) -> Value { get mutating set }
  subscript(_ i: Int) -> Vector<Value> { get mutating set }
  
  static func identity(_ size: Int) -> Self
}

extension MatrixProtocol {
  func index(after i: Int) -> Int { i + 1 }
  func index(before i: Int) -> Int { i - 1 }
  var startIndex: Int { 0 }
  var endIndex: Int { height }
  var shape: (width: Int, height: Int) { (width, height) }
  var firstIndex: (Int, Int)? { isEmpty ? nil : (0, 0) }
  var lastIndex: (Int, Int)? { isEmpty ? nil : (height - 1, width - 1) }
  
  func map(_ transform: (Vector<Value>) throws -> Vec) rethrows -> Self {
    .init(arrayLiteral: try map(transform))
  }
}

protocol Transposable where Self: MatrixProtocol {
  var transposed: Self { get }
}

protocol Initializable where Self: MatrixProtocol {
  init(_ value: Value, width: Int, height: Int)
}

extension Initializable {
  static func zeros(width: Int, height: Int) -> Self {
    .init(0, width: width, height: height)
  }
  
  static func ones(width: Int, height: Int) -> Self {
    .init(1, width: width, height: height)
  }
}

extension MatrixProtocol where Self: Transposable {
  func columnMap<T>(_ transform: (Vec) throws -> T) rethrows -> [T] {
    try transposed.map(transform)
  }
  
  func columnMap(_ transform: (Vec) throws -> Vec) rethrows -> Self {
    .init(arrayLiteral: try columnMap(transform))
  }
  
  func columnFilter(_ predicate: (Vec) throws -> Bool) rethrows -> [Vec] {
    try columnMap { $0 }.filter(predicate)
  }
  
  func columnFilter(_ predicate: (Vec) throws -> Bool) rethrows -> Self {
    .init(arrayLiteral: try columnMap { $0 }.filter(predicate))
  }
  
  func columnReduce<Result>(_ initialResult: Result, nextPartialResult: (Result, Vec) throws -> Result) rethrows -> Result {
    try transposed.reduce(initialResult, nextPartialResult)
  }
}

func == <M1: MatrixProtocol, M2: MatrixProtocol>(_ lhs: M1, _ rhs: M2) -> Bool where M1.Value == M2.Value {
  guard lhs.shape == rhs.shape else { return false }
  return zip(lhs, rhs).allSatisfy(==)
}

/// Math

func +<M: MatrixProtocol>(_ m: M, _ val: M.Value) -> M {
  m.map { $0 + val }
}

func -<M: MatrixProtocol>(_ m: M, _ val: M.Value) -> M {
  m.map { $0 - val }
}

func *<M: MatrixProtocol>(_ m: M, _ val: M.Value) -> M {
  m.map { $0 * val }
}

func /<M: MatrixProtocol>(_ m: M, _ val: M.Value) -> M {
  m.map { $0 / val }
}

func +<M: MatrixProtocol>(_ val: M.Value, _ m: M) -> M {
  m.map { $0 + val }
}

func -<M: MatrixProtocol>(_ val: M.Value, _ m: M) -> M {
  m.map { $0 - val }
}

func *<M: MatrixProtocol>(_ val: M.Value, _ m: M) -> M {
  m.map { $0 * val }
}

func /<M: MatrixProtocol>(_ val: M.Value, _ m: M) -> M {
  m.map { $0 / val }
}

func +<M: MatrixProtocol>(_ m1: M, _ m2: M) -> M {
  assert(m1.height == m2.height)
  assert(m1.width == m2.width)
  return zip(m1, m2).map { $0 + $1 }
}

func -<M: MatrixProtocol>(_ m1: M, _ m2: M) -> M {
  assert(m1.height == m2.height)
  assert(m1.width == m2.width)
  return zip(m1, m2).map { $0 - $1 }
}

func *<M: MatrixProtocol>(_ m: M, _ v: M.Vec) -> M.Vec {
  assert(m.height == v.count)
  return m.map { ($0 * v).sum }
}

func *<M>(_ m1: M, _ m2: M) -> Matrix<M.Value> where M: Transposable {
  // multiplication implemented functionaly
  assert(m1.width == m2.height)
  assert(m1.height == m2.width)
  return m1.map { v1 in
    Vector(arrayLiteral: m2.columnMap { v1.dot($0) })
  }
}

infix operator *!: MultiplicationPrecedence
func *!<M: MatrixProtocol>(_ m1: M, _ m2: M) -> Matrix<M.Value> {
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
func !/<M: MatrixProtocol>(_ v: M.Vec, _ m: M) -> M.Vec {
  // solve linear system of equations
  LUDecomposition(m, v)
}

extension Zip2Sequence where Sequence1: MatrixProtocol, Sequence2: MatrixProtocol, Sequence1.Value == Sequence2.Value {
  typealias Matrix = Sequence1
  typealias Vec = Matrix.Vec
  
  func map(_ transform: ((Vec, Vec)) throws -> Vec) rethrows -> Matrix {
    Matrix(arrayLiteral: try map(transform))
  }
}

extension Collection {
  func map<T: Mathable>(_ transform: (Element) throws -> Vector<T>) rethrows -> Matrix<T> {
    Matrix(arrayLiteral: try map(transform))
  }
}


//
//  Matrix.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

typealias Mathable = FloatingPoint

protocol MatrixProtocol: ExpressibleByArrayLiteral, Equatable, BidirectionalCollection where Element == Vector<Value> {
  associatedtype Value: Mathable
  
  var width: Int { get }
  var height: Int { get }
  
  init(width: Int, height: Int)
  init(arrayLiteral elements: [Vector<Value>])
  init(arrayLiteral elements: Vector<Value>...)
  
  subscript(_ i: Int, _ j: Int) -> Value { get set }
  subscript(_ i: Int) -> Vector<Value> { get set }
}

struct Matrix<T: Mathable>: MatrixProtocol {
  typealias Value = T
  
  let width: Int
  let height: Int
  private let buffer: UnsafeMutablePointer<Vector<T>>
  
  init(width: Int, height: Int) {
    self.width = width
    self.height = height
    self.buffer = UnsafeMutablePointer<Vector<T>>.allocate(capacity: height)
    self.buffer.assign(repeating: Vector<T>(size: width), count: height)
  }
  
  init(arrayLiteral elements: Vector<T>...) {
    self.height = elements.count
    self.width = elements.first?.count ?? 0
    self.buffer = UnsafeMutablePointer<Vector<T>>.allocate(capacity: height)
    for (i, el) in elements.enumerated() {
      buffer.advanced(by: i).assign(repeating: el, count: 1)
    }
  }
  
  init(arrayLiteral elements: [Vector<T>]) {
    self.height = elements.count
    self.width = elements.first?.count ?? 0
    self.buffer = UnsafeMutablePointer<Vector<T>>.allocate(capacity: height)
    for (i, el) in elements.enumerated() {
      buffer.advanced(by: i).assign(repeating: el, count: 1)
    }
  }
}

extension Matrix {
  subscript(_ i: Int, _ j: Int) -> T {
    get {
      assert(j >= 0)
      assert(j < width)
      return self[i][j]
    }
    mutating set {
      assert(j >= 0)
      assert(j < width)
      self[i][j] = newValue
    }
  }
}

// MARK: - Equatable
extension Matrix: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    guard lhs.width == rhs.width && lhs.height == rhs.height else { return false }
    return zip(lhs, rhs).first { $0 != $1 } == nil
  }
}

// MARK: - Collection
extension Matrix: BidirectionalCollection {
  func index(after i: Int) -> Int { i + 1 }
  func index(before i: Int) -> Int { i - 1 }
  var startIndex: Int { 0 }
  var endIndex: Int { height }
  
  subscript(_ i: Int) -> Vector<T> {
    get {
      assert(i >= 0)
      assert(i < height)
      return buffer.advanced(by: i).pointee
    }
    mutating set {
      assert(i >= 0)
      assert(i < height)
      buffer.advanced(by: i).assign(repeating: newValue, count: 1)
    }
  }
}

// MARK: - CustomDebugStringConvertible
extension Matrix: CustomDebugStringConvertible where T: LosslessStringConvertible {
  var debugDescription: String {
    "[" + map { $0.description }.joined(separator: ", ") + "]"
  }
}

// MARK: - CustomStringConvertible
extension Matrix: CustomStringConvertible where T: LosslessStringConvertible {
  var description: String { debugDescription }
}

/// Math

func +<M: MatrixProtocol>(_ m1: M, _ m2: M) -> M {
  assert(m1.height == m2.height)
  assert(m1.width == m2.width)
  return M(arrayLiteral: zip(m1, m2).map { $0 + $1 })
}

func -<M: MatrixProtocol>(_ m1: M, _ m2: M) -> M {
  assert(m1.height == m2.height)
  assert(m1.width == m2.width)
  return M(arrayLiteral: zip(m1, m2).map { $0 - $1 })
}

func *<M: MatrixProtocol>(_ m1: M, _ m2: M) -> M {
  assert(m1.height == m2.height)
  assert(m1.width == m2.width)
  return M(arrayLiteral: zip(m1, m2).map { $0 * $1 })
}

func /<M: MatrixProtocol>(_ m1: M, _ m2: M) -> M {
  assert(m1.height == m2.height)
  assert(m1.width == m2.width)
  return M(arrayLiteral: zip(m1, m2).map { $0 / $1 })
}

func *<M: MatrixProtocol>(_ m: M, _ v: Vector<M.Value>) -> Vector<M.Value> {
  assert(m.height == v.count)
  return Vector(arrayLiteral: m.map { ($0 * v).sum })
}

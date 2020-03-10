//
//  Matrix.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
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
  var shape: (width: Int, height: Int) { get }
  
  init(width: Int, height: Int)
  init(arrayLiteral elements: [Vector<Value>])
  init(arrayLiteral elements: Vector<Value>...)
  
  subscript(_ i: Int, _ j: Int) -> Value { get mutating set }
  subscript(_ i: Int) -> Vector<Value> { get mutating set }
  
  static func identity(_ size: Int) -> Self
  static func zeros(width: Int, height: Int) -> Self
  static func ones(width: Int, height: Int) -> Self
  
  mutating func swap(row: Int, col: Int)
  
  // TODO: - add other higher-order functions
  func map(_ transform: (Vector<Value>) throws -> Vec) rethrows -> Self
  func columnMap<T>(_ transform: (Vector<Value>) throws -> T) rethrows -> [T]
}

extension MatrixProtocol {
  func index(after i: Int) -> Int { i + 1 }
  func index(before i: Int) -> Int { i - 1 }
  var startIndex: Int { 0 }
  var endIndex: Int { height }
}

struct Matrix<T: Mathable>: MatrixProtocol {
  typealias Value = T
  
  private class Storage {
    let width: Int
    let height: Int
    let buffer: UnsafeMutablePointer<Vector<T>>
    
    init(width: Int, height: Int) {
      self.width = width
      self.height = height
      self.buffer = .allocate(capacity: height)
    }
    
    var copy: Storage {
      print("Creating a copy of Matrix<Vector<\(type(of: T.self))>>")
      let storage = Storage(width: width, height: height)
      for i in 0..<height {
        storage.buffer.advanced(by: i).initialize(to: self.buffer.advanced(by: i).pointee)
      }
      return storage
    }
  }
  private var storage: Storage
  
  init(width: Int, height: Int) {
    self.storage = Storage(width: width, height: height)
    for i in 0..<height {
      storage.buffer.advanced(by: i).initialize(to: .init(size: width))
    }
  }
  
  init(arrayLiteral elements: Vector<T>...) {
    self.storage = Storage(width: elements.first?.count ?? 0, height: elements.count)
    for (i, el) in elements.enumerated() {
      storage.buffer.advanced(by: i).initialize(to: el)
    }
  }
  
  init(arrayLiteral elements: [Vector<T>]) {
    self.storage = Storage(width: elements.first?.count ?? 0, height: elements.count)
    for (i, el) in elements.enumerated() {
      storage.buffer.advanced(by: i).initialize(to: el)
    }
  }
}

private extension Matrix {
  // copy-on-write
  private var storageForWriting: Storage {
    mutating get {
      if !isKnownUniquelyReferenced(&storage) {
        self.storage = storage.copy
      }
      return storage
    }
  }
}

// MARK: - API
extension Matrix {
  var width: Int { storage.width }
  var height: Int { storage.height }
  var shape: (width: Int, height: Int) { (width, height) }
  
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
  
  var transposed: Self {
    var transposed = Matrix(width: height, height: width)
    for i in 0..<height {
      for j in 0..<width {
        transposed[j, i] = self[i, j]
      }
    }
    return transposed
  }
  
  mutating func swap(row: Int, col: Int) {
    let tmp = storage.buffer.advanced(by: row).pointee
    storage.buffer.advanced(by: row).initialize(to: storage.buffer.advanced(by: col).pointee)
    storage.buffer.advanced(by: col).initialize(to: tmp)
  }
  
  static func identity(_ size: Int) -> Self {
    (0..<size).map {
      var vec = Vector<T>.zeros(size)
      vec[$0] = 1
      return vec
    }
  }
  
  static func zeros(width: Int, height: Int) -> Self {
    (0..<height).map { _ in .zeros(width) }
  }
  
  static func ones(width: Int, height: Int) -> Self {
    (0..<height).map { _ in .ones(width) }
  }
  
  // collection
  
  func map(_ transform: (Vector<Value>) throws -> Vec) rethrows -> Matrix {
    Matrix(arrayLiteral: try map(transform))
  }
  
  func columnMap<T>(_ transform: (Vector<Value>) throws -> T) rethrows -> [T] {
    try transposed.map(transform)
  }
}

// MARK: - Equatable
extension Matrix: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    guard lhs.shape == rhs.shape else { return false }
    return zip(lhs, rhs).first { $0 != $1 } == nil
  }
}

// MARK: - Collection
extension Matrix: BidirectionalCollection {
  subscript(_ i: Int) -> Vector<T> {
    get {
      assert(i >= 0)
      assert(i < height)
      return storage.buffer.advanced(by: i).pointee
    }
    mutating set {
      assert(i >= 0)
      assert(i < height)
      storageForWriting.buffer.advanced(by: i).assign(repeating: newValue, count: 1)
    }
  }
}

// MARK: - CustomDebugStringConvertible
extension Matrix: CustomDebugStringConvertible where T: LosslessStringConvertible {
  var debugDescription: String {
    "[" + map { $0.description }.joined(separator: "\n") + "]"
  }
}

// MARK: - CustomStringConvertible
extension Matrix: CustomStringConvertible where T: LosslessStringConvertible {
  var description: String { debugDescription }
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
  return Vector(arrayLiteral: m.map { ($0 * v).sum })
}

func *<M: MatrixProtocol>(_ m1: M, _ m2: M) -> M {
  // multiplication implemented functionaly
  assert(m1.width == m2.height)
  assert(m1.height == m2.width)
  return m1.map { v1 in
    Vector(arrayLiteral: m2.columnMap { v1.dot($0) })
  }
}

infix operator *!: MultiplicationPrecedence
func *!<M: MatrixProtocol>(_ m1: M, _ m2: M) -> M {
  // multiplication implemented proceduraly
  assert(m1.width == m2.height)
  assert(m1.height == m2.width)
  var res = M(width: m2.width, height: m1.height)
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
func !/<M: MatrixProtocol>(_ m: M, _ v: M.Vec) -> M.Vec {
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

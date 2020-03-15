//
//  Vector.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

struct Vector<T: Mathable>: ExpressibleByArrayLiteral {
  private let size: Int
  // implementation detail
  // should we replace with [T] instead?
  private let buffer: UnsafeMutablePointer<T>
  
  init() {
    self.size = 0
    self.buffer = UnsafeMutablePointer<T>.allocate(capacity: self.size)
  }
  
  init(size: Int) {
    self.size = size
    self.buffer = UnsafeMutablePointer<T>.allocate(capacity: self.size)
  }
  
  init(arrayLiteral elements: T...) {
    self.size = elements.count
    self.buffer = UnsafeMutablePointer<T>.allocate(capacity: self.size)
    for (i, el) in elements.enumerated() {
      buffer.advanced(by: i).assign(repeating: el, count: 1)
    }
  }
  
  init(arrayLiteral elements: [T]) {
    self.size = elements.count
    self.buffer = UnsafeMutablePointer<T>.allocate(capacity: self.size)
    for (i, el) in elements.enumerated() {
      buffer.advanced(by: i).assign(repeating: el, count: 1)
    }
  }
}

extension Vector {
  var sum: T { reduce(T.zero, +) }
  var avg: T { sum / T(size) }
  var len: T { sqrt(map { $0 * $0 }.reduce(T.zero, +)) }
}

// MARK: - Equatable
extension Vector: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    guard lhs.count == rhs.count else { return false }
    return zip(lhs, rhs).first { $0 != $1 } == nil
  }
}

// MARK: - BidirectionalCollection
extension Vector: BidirectionalCollection {
  func index(after i: Int) -> Int { i + 1 }
  func index(before i: Int) -> Int { i - 1 }
  var startIndex: Int { 0 }
  var endIndex: Int { size }
  
  subscript(_ i: Int) -> T {
    get {
      assert(i >= 0)
      assert(i < size)
      return buffer.advanced(by: i).pointee
    }
    set {
      assert(i >= 0)
      assert(i < size)
      buffer.advanced(by: i).assign(repeating: newValue, count: 1)
    }
  }
}

// MARK: - CustomDebugStringConvertible
extension Vector: CustomDebugStringConvertible where T: LosslessStringConvertible {
  var debugDescription: String {
    "[" + map { String($0) }.joined(separator: ", ") + "]"
  }
}

// MARK: - CustomStringConvertible
extension Vector: CustomStringConvertible where T: LosslessStringConvertible {
  var description: String { debugDescription }
}

/// Math

func +<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return Vector(arrayLiteral: zip(v1, v2).map { $0 + $1 })
}

func -<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return Vector(arrayLiteral: zip(v1, v2).map { $0 - $1 })
}

func *<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return Vector(arrayLiteral: zip(v1, v2).map { $0 * $1 })
}

func /<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return Vector(arrayLiteral: zip(v1, v2).map { $0 / $1 })
}

func cos<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  Vector(arrayLiteral: v.map { T(cos(Double($0))) })
}

func sin<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  Vector(arrayLiteral: v.map { T(sin(Double($0))) })
}

func sqrt<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  Vector(arrayLiteral: v.map { T(sqrt(Double($0))) })
}

func log2<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  Vector(arrayLiteral: v.map { T(log2(Double($0))) })
}

func log<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  Vector(arrayLiteral: v.map { T(log(Double($0))) })
}

//
//  Vector.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

struct Vector<T: Mathable>: ExpressibleByArrayLiteral {
  typealias Pointee = T
  typealias U = ()
  
  var storage: COW
  
  init() {
    self.storage = .init(capacity: 0, provider: nil)
  }
  
  init(size: Int) {
    self.storage = .init(capacity: size, provider: nil)
  }
  
  init(arrayLiteral elements: T...) {
    self.storage = .init(elements: elements)
  }
  
  init(arrayLiteral elements: [T]) {
    self.storage = .init(elements: elements)
  }
}

// MARK: - SupportsCopyOnWrite
extension Vector: SupportsCopyOnWrite {
}

extension Vector {
  var sum: T { reduce(T.zero, +) }
  var avg: T { sum / T(count) }
  var len: T { sqrt(map { $0 * $0 }.reduce(T.zero, +)) }
}

extension Vector {
  static func zeros(_ count: Int) -> Self {
    Vector(arrayLiteral: Array(repeating: T.zero, count: count))
  }
  
  static func ones(_ count: Int) -> Self {
    Vector(arrayLiteral: Array(repeating: 1, count: count))
  }
  
  static func repeating(_ count: Int, value: T) -> Self {
    Vector(arrayLiteral: Array(repeating: value, count: count))
  }

  func dot(_ v: Vector<T>) -> T {
    assert(count == v.count)
    return zip(self, v).map { $0 * $1 }.reduce(0, +)
  }
}

// MARK: - Equatable
extension Vector: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    guard lhs.count == rhs.count else { return false }
    return zip(lhs, rhs).allSatisfy(==)
  }
}

// MARK: - BidirectionalCollection
extension Vector: BidirectionalCollection {
  func index(after i: Int) -> Int { i + 1 }
  func index(before i: Int) -> Int { i - 1 }
  var startIndex: Int { 0 }
  var endIndex: Int { storage.capacity }
  
  subscript(_ i: Int) -> T {
    get {
      assert(i >= 0)
      assert(i < count)
      return storage.buffer[i]
    }
    mutating set {
      assert(i >= 0)
      assert(i < count)
      storageForWriting[i] = newValue
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

extension Zip2Sequence {
  func map<T: Mathable>(_ transform: ((Sequence1.Element, Sequence2.Element)) throws -> T) rethrows -> Vector<T> {
    Vector(arrayLiteral: try map(transform))
  }
}

extension Collection {
  func map<T: Mathable>(_ transform: (Element) throws -> T) rethrows -> Vector<T> {
    Vector(arrayLiteral: try map(transform))
  }
}

/// Math

func +<T: Mathable>(_ v: Vector<T>, _ num: T) -> Vector<T> {
  v.map { $0 + num }
}

func -<T: Mathable>(_ v: Vector<T>, _ num: T) -> Vector<T> {
  v.map { $0 - num }
}

func *<T: Mathable>(_ v: Vector<T>, _ num: T) -> Vector<T> {
  v.map { $0 * num }
}

func /<T: Mathable>(_ v: Vector<T>, _ num: T) -> Vector<T> {
  v.map { $0 / num }
}

func +<T: Mathable>(_ num: T, _ v: Vector<T>) -> Vector<T> {
  v.map { $0 + num }
}

func -<T: Mathable>(_ num: T, _ v: Vector<T>) -> Vector<T> {
  v.map { $0 - num }
}

func *<T: Mathable>(_ num: T, _ v: Vector<T>) -> Vector<T> {
  v.map { $0 * num }
}

func /<T: Mathable>(_ num: T, _ v: Vector<T>) -> Vector<T> {
  v.map { $0 / num }
}

func +<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return zip(v1, v2).map { $0 + $1 }
}

func -<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return zip(v1, v2).map { $0 - $1 }
}

func *<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return zip(v1, v2).map { $0 * $1 }
}

func /<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return zip(v1, v2).map { $0 / $1 }
}

func cos<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(cos(Double($0))) }
}

func sin<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(sin(Double($0))) }
}

func sqrt<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(sqrt(Double($0))) }
}

func log2<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(log2(Double($0))) }
}

func log<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(log(Double($0))) }
}

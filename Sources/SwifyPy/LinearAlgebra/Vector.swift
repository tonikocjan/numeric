//
//  Vector.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

public struct Vector<T: Mathable>: ExpressibleByArrayLiteral {
  var storage: COW
  
  public init() {
    self.storage = .init(capacity: 0, provider: nil)
  }
  
  public init(size: Int) {
    self.storage = .init(capacity: size, provider: nil)
  }
  
  public init(arrayLiteral elements: T...) {
    self.storage = .init(elements: elements)
  }
  
  public init(arrayLiteral elements: [T]) {
    self.storage = .init(elements: elements)
  }
}

// MARK: - SupportsCopyOnWrite
extension Vector: SupportsCopyOnWrite {
  typealias Pointee = T
  typealias U = ()
}

public extension Vector {
  var sum: T { reduce(T.zero, +) }
  var avg: T { sum / T(count) }
  var len: T { sqrt(map { $0 * $0 }.reduce(T.zero, +)) }
}

public extension Vector {
  static func zeros(_ count: Int) -> Self {
    repeating(count, value: 0)
  }
  
  static func ones(_ count: Int) -> Self {
    repeating(count, value: 1)
  }
  
  static func repeating(_ count: Int, value: T) -> Self {
    .init(arrayLiteral: Array(repeating: value, count: count))
  }

  func dot(_ v: Vector<T>) -> T {
    assert(count == v.count)
    return zip(self, v).map { $0 * $1 }.reduce(0, +)
  }
}

// MARK: - Equatable
extension Vector: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    guard lhs.count == rhs.count else { return false }
    return zip(lhs, rhs).allSatisfy(==)
  }
}

// MARK: - BidirectionalCollection
extension Vector: BidirectionalCollection {
  public func index(after i: Int) -> Int { i + 1 }
  public func index(before i: Int) -> Int { i - 1 }
  public var startIndex: Int { 0 }
  public var endIndex: Int { storage.capacity }
  
  public subscript(_ i: Int) -> T {
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
  public var debugDescription: String {
    "[" + map { String($0) }.joined(separator: ", ") + "]"
  }
}

// MARK: - CustomStringConvertible
extension Vector: CustomStringConvertible where T: LosslessStringConvertible {
  public var description: String { debugDescription }
}

extension Zip2Sequence {
  public func map<T: Mathable>(_ transform: ((Sequence1.Element, Sequence2.Element)) throws -> T) rethrows -> Vector<T> {
    Vector(arrayLiteral: try map(transform))
  }
}

extension Collection {
  public func map<T: Mathable>(_ transform: (Element) throws -> T) rethrows -> Vector<T> {
    Vector(arrayLiteral: try map(transform))
  }
}

/// Math

public func +<T: Mathable>(_ v: Vector<T>, _ num: T) -> Vector<T> {
  v.map { $0 + num }
}

public func -<T: Mathable>(_ v: Vector<T>, _ num: T) -> Vector<T> {
  v.map { $0 - num }
}

public func *<T: Mathable>(_ v: Vector<T>, _ num: T) -> Vector<T> {
  v.map { $0 * num }
}

public func /<T: Mathable>(_ v: Vector<T>, _ num: T) -> Vector<T> {
  v.map { $0 / num }
}

public func +<T: Mathable>(_ num: T, _ v: Vector<T>) -> Vector<T> {
  v.map { $0 + num }
}

public func -<T: Mathable>(_ num: T, _ v: Vector<T>) -> Vector<T> {
  v.map { num - $0 }
}

public func *<T: Mathable>(_ num: T, _ v: Vector<T>) -> Vector<T> {
  v.map { $0 * num }
}

public func /<T: Mathable>(_ num: T, _ v: Vector<T>) -> Vector<T> {
  v.map { num / $0 }
}

public func +<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return zip(v1, v2).map { $0 + $1 }
}

public func -<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return zip(v1, v2).map { $0 - $1 }
}

public func *<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return zip(v1, v2).map { $0 * $1 }
}

public func /<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return zip(v1, v2).map { $0 / $1 }
}

public func cos<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(cos(Double($0))) }
}

public func sin<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(sin(Double($0))) }
}

public func sqrt<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(sqrt(Double($0))) }
}

public func log2<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(log2(Double($0))) }
}

public func log<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(log(Double($0))) }
}

//
//  Vector.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

/**
 # Vector
 
 A vector is a list of numbers.
 
 There are (at least) two ways to interpret what this list of numbers mean:

   1. One way to think of the vector as being a point in a space.
 Then this list of numbers is a way of identifying that point in space,
 where each number represents the vector’s component that
 dimension.
 
   2. Another way to think of a vector is a magnitude and a direction, e.g. a
 quantity like velocity. In this way of a vector is a directed arrow pointing
 from the origin to the end point given by the list ofnumbers.
 */
public struct Vector<T: Mathable>: ExpressibleByArrayLiteral {
  /// Implementation detail, not exposed to the users.
  var storage: COW
  
  /**
   Initialize a new vector with zero elements.
   
   - Returns: A new vector with zero elements.
   */
  public init() {
    self.storage = .init(capacity: 0, provider: nil)
  }
  
  /**
   Initialize a new vector with provided number of elements. The components of the new vector don't have a default value,
   i.e, they are _random_.
   
   - Parameter size: Size (number of elements) of new vector.
   
   - Returns: A new vector with the provided number of elements whose values are not initialized.
   */
  public init(size: Int) {
    self.storage = .init(capacity: size, provider: nil)
  }
  
  /**
   Initialize a new vector number of elements will match the number of elements in the provided list.
   The elements of the vector will be initialized to the values inside `elements`.
   
   - Parameter elements: A list containing values.
   
   - Returns: A new vector containing values from the `arrayLiteral`.
   */
  public init(arrayLiteral elements: T...) {
    self.storage = .init(elements: elements)
  }
  
  /**
   Initialize a new vector number of elements will match the number of elements in the provided list.
   The elements of the vector will be initialized to the values inside `elements`.
   
   - Parameter elements: A list containing values.
   
   - Returns:  A new vector containing values from the `arrayLiteral`.
   */
  public init(arrayLiteral elements: [T]) {
    self.storage = .init(elements: elements)
  }
}

// MARK: - Public API
public extension Vector {
  /**
   Sums the values inside this vector.
   
   For instance:
       
       let v: Vector = [1, 2, 3]
       v.sum // 6
   */
  var sum: T { reduce(T.zero, +) }
  
  /**
   Average value of this vector.
   
   Average is equivalent to sum divided by number of elements.
  
   For instance:
      
       let v: Vector = [1, 2, 3]
       v.avg // 2
  */
  var avg: T { sum / T(count) }
  
  /**
   Length (or magnitude) of this vector.
   
   The `magnitude` of a vector is the distance from the endpoint of the vector to the origin.
   
   For instance:
   
        let v: Vector [4, 3]
        v.len // sqrt(4 * 4 + 3 * 3) = 5
   */
  var magnitude: T { sqrt(map { $0 * $0 }.reduce(T.zero, +)) }
  
  /**
   Compute a `unit` vector from this vector.
   
   A unit vector is a vector of length 1, sometimes also called a direction vector.
   
   For instance:
   
        let v: Vector [4, 3]
        v.unit // [4 / 5, 3 / 5]
   */
  var unit: Vector<T> {
    self / magnitude
  }
  
  /**
   Create a new vector with the given number of elements initialized to a provided value.
   
   - Parameters:
       - count: Number of elements in new vector.
   
   - Returns: A new vector of desired size with elements initialized to a default value.
   */
  static func repeating(_ count: Int, value: T) -> Self {
    .init(arrayLiteral: Array(repeating: value, count: count))
  }

  /**
  Create a new vector with the given number of elements initialized to zero.
  
  - Parameters:
      - count: Number of elements in new vector.
  
  - Returns: A new vector of desired size with elements initialized to zero.
  */
  static func zeros(_ count: Int) -> Self {
    repeating(count, value: 0)
  }
  
  /**
  Create a new vector with the given number of elements initialized to one.
  
  - Parameters:
      - count: Number of elements in new vector.
  
  - Returns: A new vector of desired size with elements initialized to one.
  */
  static func ones(_ count: Int) -> Self {
    repeating(count, value: 1)
  }
  
  /**
   Compute the `dot` product of this vector with some other vector.
   
   Algebraically, the dot product is the sum of the products of the corresponding entries of the two vectors.
   
   The number of elements of both vectors must match.
   
   - Parameter v: The other vector.
   
   - Returns: The dot product of both vectors.
   */
  func dot(_ v: Vector<T>) -> T {
    assert(count == v.count)
    return zip(self, v).map { $0 * $1 }.sum
  }
}

// MARK: - Equatable
extension Vector: Equatable {
  /**
   Compares two vectors for equality.
   
   Two vectors are equal when they have the same number of elements and their elements match component-wise.
   
   - Parameters:
       - lhs: First vector.
       - rhs: Second vector.
   
   - Returns: `true` if vectors are equal, `false` otherwise.
   */
  public static func ==(lhs: Self, rhs: Self) -> Bool {
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
  
  /**
   Access the element at the specified position.
   
   You can subscript a vector with any valid index which is greater or equal to zero
   and less than `count`. If the index is outside this range, the program will crash!
   
   For instance:
   
       let vector: Vector = [1, 2, 3]
       print(vector[0]) // 1
       print(vector[2]) // 3
       // print(vector[3]) - error, `3` not valid index
   
   - Parameter position: The position of the element to access.
   */
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

/// Math

/// Add a constant to every element of the vector.
public func +<T: Mathable>(_ v: Vector<T>, _ num: T) -> Vector<T> {
  v.map { $0 + num }
}

/// Subtract a constant from every element of the vector.
public func -<T: Mathable>(_ v: Vector<T>, _ num: T) -> Vector<T> {
  v.map { $0 - num }
}

/// Multiply a constant with every element of the vector.
public func *<T: Mathable>(_ v: Vector<T>, _ num: T) -> Vector<T> {
  v.map { $0 * num }
}

/// Divide every element of the vector with a constant.
public func /<T: Mathable>(_ v: Vector<T>, _ num: T) -> Vector<T> {
  v.map { $0 / num }
}

/// Add a constant to every element of the vector.
public func +<T: Mathable>(_ num: T, _ v: Vector<T>) -> Vector<T> {
  v.map { $0 + num }
}

/// Subtract every element of the vector from a constant.
public func -<T: Mathable>(_ num: T, _ v: Vector<T>) -> Vector<T> {
  v.map { num - $0 }
}

/// Multiply a constant with every element of the vector.
public func *<T: Mathable>(_ num: T, _ v: Vector<T>) -> Vector<T> {
  v.map { $0 * num }
}

/// Divide a constant with every element of the vector.
public func /<T: Mathable>(_ num: T, _ v: Vector<T>) -> Vector<T> {
  v.map { num / $0 }
}

/// Divide a constant with every element of the vector.
public prefix func -<T: Mathable>(_ v: Vector<T>) -> Vector<T> {
  -1 * v
}

/// Element-wise vector addition.
public func +<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return zip(v1, v2).map { $0 + $1 }
}

/// Element-wise vector multiplication.
public func -<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return zip(v1, v2).map { $0 - $1 }
}

/// Element-wise vector multiplication.
public func *<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return zip(v1, v2).map { $0 * $1 }
}

/// Element-wise vector division.
public func /<T: Mathable>(_ v1: Vector<T>, _ v2: Vector<T>) -> Vector<T> {
  assert(v1.count == v2.count)
  return zip(v1, v2).map { $0 / $1 }
}

/// Element-wise `cos`.
public func cos<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(cos(Double($0))) }
}

/// Element-wise `sin`.
public func sin<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(sin(Double($0))) }
}

/// Element-wise `sqrt`.
public func sqrt<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(sqrt(Double($0))) }
}

/// Element-wise `log2`.
public func log2<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(log2(Double($0))) }
}

/// Element-wise `log`.
public func log<T: BinaryFloatingPoint>(_ v: Vector<T>) -> Vector<T> {
  v.map { T(log(Double($0))) }
}

/// - - - - -

extension Zip2Sequence {
  public func map<T: Mathable>(_ transform: ((Sequence1.Element, Sequence2.Element)) throws -> T) rethrows -> Vector<T> {
    .init(arrayLiteral: try map(transform))
  }
}

extension Collection {
  public func map<T: Mathable>(_ transform: (Element) throws -> T) rethrows -> Vector<T> {
    .init(arrayLiteral: try map(transform))
  }
}


// MARK: - SupportsCopyOnWrite
extension Vector: SupportsCopyOnWrite {
  typealias Pointee = T
  typealias U = ()
}

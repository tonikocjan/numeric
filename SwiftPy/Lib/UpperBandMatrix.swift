//
//  UpperBandMatrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 10/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

struct UpperBandMatrix<T: Mathable>: MatrixProtocol {
  typealias Value = T
  typealias Pointee = Vector<T>
  typealias U = Int
  
  var storage: COW
  
  /// Initialize a new **Upper Band** matrix with specified size.
  ///
  /// - Parameter width: number of sub-diagonals in the upper triangle with non-zero elements
  ///                    when width = 0 this is a diagonal matrix
  ///
  /// - Parameter height: height of the matrix
  ///
  init(width: Int, height: Int) {
    storage = .init(capacity: width + 1, size: height) { Vector(size: height - $0) }
  }
  
  /// Initialize a new **Upper Band** matrix from the given `elements`
  ///
  /// - Parameter elements: the `count` of elements specifies the height of this matrix
  ///
  init(arrayLiteral elements: Vector<Value>...) {
    self.init(arrayLiteral: elements)
  }
  
  // first element's `count` is the height of the matrix
  init(arrayLiteral elements: [Vector<Value>]) {
    assert(elements.count > 0) // TODO: - Can we construct an empty matrix?
    for (i, el) in elements.dropFirst().enumerated() {
      assert(elements[i].count == el.count + 1)
    }
    
    storage = .init(capacity: elements.count, size: elements[0].count) { elements[$0] }
  }
}

// MARK: - SupportsCopyOnWrite
extension UpperBandMatrix: SupportsCopyOnWrite {}

// MARK: - Equatable
extension UpperBandMatrix: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.storage == rhs.storage
  }
}

extension UpperBandMatrix {
  var width: Int { storage.size! }
  var height: Int { width }
  var k: Int { storage.capacity - 1 }
  
  subscript(_ i: Int, _ j: Int) -> T {
    get {
      assert(j >= 0)
      assert(j < width)
      if i > j { return .zero }
      if j - i > k { return .zero }
      return storage[j - i][i]
    }
    mutating set {
      assert(j >= 0)
      assert(j < width)
      if i > j { assert(newValue == 0) }
      if j - i > k { assert(newValue == 0) }
      storageForWriting[j - i][i] = newValue
    }
  }
  
  var transposed: Self {
    fatalError()
  }
  
  mutating func swap(row: Int, col: Int) {
    fatalError()
  }
  
  static func identity(_ size: Int) -> Self {
    UpperBandMatrix(arrayLiteral: [.ones(size)])
  }
  
  static func zeros(width: Int, height: Int) -> Self {
    fatalError("Not a valid operation")
  }
  
  static func ones(width: Int, height: Int) -> Self {
    fatalError("Not a valid operation")
  }
}

// MARK: - Collection
extension UpperBandMatrix: BidirectionalCollection {
  subscript(_ i: Int) -> Vector<T> {
    get {
      assert(i >= 0)
      assert(i < height)
      return (0..<height).map { self[i, $0] }
    }
    mutating set {
      assert(i >= 0)
      assert(i < height)
      // TODO: -
    }
  }
}


// MARK: - CustomDebugStringConvertible
extension UpperBandMatrix: CustomDebugStringConvertible where T: LosslessStringConvertible {
  var debugDescription: String {
    "[" + map { $0.description }.joined(separator: "\n") + "]"
  }
}

// MARK: - CustomStringConvertible
extension UpperBandMatrix: CustomStringConvertible where T: LosslessStringConvertible {
  var description: String { debugDescription }
}

var RBM_ITERATIONS_COUNT = 0 // for testing purposes

func *<T: Mathable>(_ lhs: UpperBandMatrix<T>, _ rhs: Vector<T>) -> Vector<T> {
  assert(lhs.height == rhs.count)
  var result: Vector<T> = .zeros(lhs.height)
  RBM_ITERATIONS_COUNT = 0
  for i in 0..<lhs.height {
    for j in i..<Swift.min(i + lhs.k + 1, lhs.height) {
      result[i] += lhs[i, j] * rhs[j]
      RBM_ITERATIONS_COUNT += 1
    }
  }
  return result
}

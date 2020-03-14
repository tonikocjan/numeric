//
//  LowerBandMatrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 10/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

struct LowerBandMatrix<T: Mathable>: BandMatrixProtocol {
  typealias Value = T
  typealias Pointee = Vector<T>
  typealias U = Int
  
  var storage: COW
  
  /// Initialize a new **Upper Band** matrix with specified size.
  ///
  /// - Parameter k: number of sub-diagonals in the upper triangle with non-zero elements
  ///                when k = 0 this is a diagonal matrix
  ///
  /// - Parameter height: height of the matrix
  ///
  init(bandwidth: Int, height: Int) {
    storage = .init(capacity: bandwidth, size: height) { Vector(size: height - $0) }
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

extension LowerBandMatrix {
  var width: Int { storage.size! }
  var height: Int { width }
  
  // number of non-zero diagonals
  var bandwidth: Int { storage.capacity }
  
  var isDiagonalyDominant: Bool {
    guard bandwidth > 1 else { return true }
    for i in 0..<height {
      var sum: Value = 0
      for j in stride(from: i - 1, to: Swift.max(i - bandwidth, 0), by: -1) {
        sum += self[i, j]
      }
      if sum > self[i, i] { return false }
    }
    return true
  }
  
  subscript(_ i: Int, _ j: Int) -> T {
    get {
      assert(j >= 0)
      assert(j < width)
      if j > i { return .zero }
      let diag = i - j
      if diag >= bandwidth { return .zero }
      return storage[diag][j]
    }
    mutating set {
      assert(j >= 0)
      assert(j < width)
      if j > i { return assert(newValue == 0) }
      if i - j >= bandwidth { return assert(newValue == 0) }
      storageForWriting[i - j][j] = newValue
    }
  }
  
  static func identity(_ size: Int) -> Self {
    LowerBandMatrix(arrayLiteral: [.ones(size)])
  }
}

// MARK: - SupportsCopyOnWrite
extension LowerBandMatrix: SupportsCopyOnWrite {}

// MARK: - Equatable
extension LowerBandMatrix: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.storage == rhs.storage
  }
}

// MARK: - Collection
extension LowerBandMatrix: BidirectionalCollection {
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
extension LowerBandMatrix: CustomDebugStringConvertible where T: LosslessStringConvertible {
  var debugDescription: String {
    "[" + map { $0.description }.joined(separator: "\n") + "]"
  }
}

// MARK: - CustomStringConvertible
extension LowerBandMatrix: CustomStringConvertible where T: LosslessStringConvertible {
  var description: String { debugDescription }
}

var LBM_ITERATIONS_COUNT = 0 // for testing purposes

func *<T: Mathable>(_ lhs: LowerBandMatrix<T>, _ rhs: Vector<T>) -> Vector<T> {
  assert(lhs.height == rhs.count)
  LBM_ITERATIONS_COUNT = 0
  var result: Vector<T> = .zeros(lhs.height)
  for i in 0..<lhs.height {
    for j in Swift.max(0, i - (lhs.height - lhs.bandwidth) + 1)...i {
      result[i] += lhs[i, j] * rhs[j]
      LBM_ITERATIONS_COUNT += 1
    }
  }
  return result
}

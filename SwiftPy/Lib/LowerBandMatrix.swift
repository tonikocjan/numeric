//
//  LowerBandMatrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 10/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

struct LowerBandMatrix<T: Mathable>: MatrixProtocol {
  typealias Value = T
  private let storage: UnsafeMutablePointer<Vector<T>>
  let height: Int
  let k: Int
  
  /// Initialize a new **Upper Band** matrix with specified size.
  ///
  /// - Parameter width: number of sub-diagonals in the upper triangle with non-zero elements
  ///                    when width = 0 this is a diagonal matrix
  ///
  /// - Parameter height: height of the matrix
  ///
  init(width: Int, height: Int) {
    self.k = width
    self.height = height
    storage = .allocate(capacity: k + 1)
    for i in 0..<(k + 1) {
      storage.advanced(by: i).initialize(to: Vector(size: height - i))
    }
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
    self.k = elements.count - 1
    self.storage = .allocate(capacity: k + 1)
    self.height = elements[0].count
    for (i, el) in elements.enumerated() {
      storage.advanced(by: i).initialize(to: el)
    }
  }
}

extension LowerBandMatrix {
  var width: Int { height }
  
  subscript(_ i: Int, _ j: Int) -> T {
    get {
      assert(j >= 0)
      assert(j < width)
      if j > i { return .zero }
      let diag = i - j
      if diag > k { return .zero }
      return storage[diag][j]
    }
    mutating set {
      assert(j >= 0)
      assert(j < width)
      if j > i { return assert(newValue == 0) }
      if i - j > k { return assert(newValue == 0) }
      storage[i - j][j] = newValue
    }
  }
  
  var transposed: Self {
    fatalError()
  }
  
  mutating func swap(row: Int, col: Int) {
    fatalError()
  }
  
  static func identity(_ size: Int) -> Self {
    LowerBandMatrix(arrayLiteral: [.ones(size)])
  }
  
  static func zeros(width: Int, height: Int) -> Self {
    fatalError("Not a valid operation")
  }
  
  static func ones(width: Int, height: Int) -> Self {
    fatalError("Not a valid operation")
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
    for j in Swift.max(0, i - (lhs.height - lhs.k) + 2)...i {
      result[i] += lhs[i, j] * rhs[j]
      LBM_ITERATIONS_COUNT += 1
    }
  }
  return result
}

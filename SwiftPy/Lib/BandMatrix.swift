//
//  TriangularMatrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 09/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

/// **Band** matrix
///
/// - Author: Toni K. Turk
///
/// In mathematics, particularly matrix theory, a band matrix is a sparse matrix whose non-zero entries are
/// confined to a diagonal band, comprising the main diagonal and zero or more diagonals on either side.
///
struct BandMatrix<T: Mathable>: MatrixProtocol {
  typealias Value = T
  
  // upper matrix contains diagonal elements!
  private var upper: UpperBandMatrix<T>
  private var lower: LowerBandMatrix<T>
  
  /// Initialize a new **Band** matrix with specified size.
  ///
  /// - Parameter width: number of sub-diagonals with non-zero elements.
  ///                      - if width = 0 this is **diagonal** matrix
  ///                      - if width = 1 this is **tridiagonal** matrix
  ///                      - ...
  ///
  /// - Parameter height: height of the matrix
  ///
  init(k: Int, height: Int) {
    upper = .init(k: k + 1, height: height)
    lower = .init(k: k, height: height - 1)
  }
  
  init(width: Int, height: Int) {
    fatalError()
  }
  
  /// Initialize a new **Band** matrix from the given `elements`
  ///
  /// - Parameter elements: the `count` of elements specifies the height of this matrix
  ///
  ///
  /// - Example: 1> BandMatrix(elemenets: [[1], [2], [3]]) creates matrix:
  /// [[1, 0, 0],
  ///  [0, 2, 0],
  ///  [0, 0, 3]]
  ///
  /// - Example: 1> BandMatrix(elemenets: [[1, 2], [3, 4, 5], [6, 7]]) creates matrix:
  /// [[1, 2, 0],
  ///  [3, 4, 5],
  ///  [0, 6, 7]]
  ///
  init(arrayLiteral elements: Vector<Value>...) {
    self.init(arrayLiteral: elements)
  }
  
  init(arrayLiteral elements: [Vector<Value>]) {
    func calculateK(_ count: Int) -> Int {
      count == 1 ? 0 : Int(floor(Double(count) / 2))
    }
    
    assert(elements.count > 0, "Cannot construct an empty BandMatrix!") // TODO: - Can we construct an empty matrix?
    assert(elements.first!.count == elements.last!.count, "First and last row must contain the same number of elements.")
    if elements.count > 1 {
      assert(elements.first!.count == 1 || elements.first!.count == elements[1].count - 1, "First row must be one less then middle rows!")
      assert(elements.last!.count == 1 || elements.last!.count == elements[1].count - 1, "Last row must be one less then middle rows!")
    }
    let k = calculateK(elements.dropFirst().first?.count ?? elements[0].count)
    for el in elements.dropFirst().dropLast() {
      assert(k == calculateK(el.count))
    }
    
    self.init(k: k, height: elements.count)
    for i in 0..<height {
      let offset = Swift.max(0, (height - k - (height - i)))
      for (j, el) in elements[i].enumerated() {
        self[i, j + offset] = el
      }
    }
  }
}


// MARK: - API
extension BandMatrix {
  var width: Int { upper.height }
  var height: Int { upper.height }
  var k: Int { upper.k + lower.k }
  
  subscript(_ i: Int, _ j: Int) -> T {
    get {
      if i > j {
        return lower[i - 1, j]
      }
      return upper[i, j]
    }
    mutating set {
      if i > j {
        lower[i - 1, j] = newValue
        return
      }
      upper[i, j] = newValue
    }
  }
  
  var transposed: Self {
    fatalError()
  }
  
  mutating func swap(row: Int, col: Int) {
    fatalError()
  }
  
  static func identity(_ size: Int) -> Self {
    var matrix = BandMatrix(k: 0, height: size)
    for i in 0..<size {
      matrix[i, i] = 1
    }
    return matrix
  }
  
  static func zeros(width: Int, height: Int) -> Self {
    fatalError("Not a valid operation")
  }
  
  static func ones(width: Int, height: Int) -> Self {
    fatalError("Not a valid operation")
  }
}

// MARK: - Equatable
extension BandMatrix: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.upper == rhs.upper && lhs.lower == rhs.lower
  }
}

// MARK: - Collection
extension BandMatrix: BidirectionalCollection {
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
extension BandMatrix: CustomDebugStringConvertible where T: LosslessStringConvertible {
  var debugDescription: String {
    "[" + map { $0.description }.joined(separator: "\n") + "]"
  }
}

// MARK: - CustomStringConvertible
extension BandMatrix: CustomStringConvertible where T: LosslessStringConvertible {
  var description: String { debugDescription }
}

var BM_ITERATIONS_COUNT = 0 // for testing purposes

func *<T: Mathable>(_ lhs: BandMatrix<T>, _ rhs: Vector<T>) -> Vector<T> {
  assert(lhs.height == rhs.count)
  var result: Vector<T> = .zeros(lhs.height)
  BM_ITERATIONS_COUNT = 0
  for i in 0..<lhs.height {
    let lower = Swift.max(0, i - (lhs.height - lhs.k) + 2)
    let upper = Swift.min(i + lhs.k + 1, lhs.height)
    for j in lower..<upper {
      result[i] += lhs[i, j] * rhs[j]
      BM_ITERATIONS_COUNT += 1
    }
  }
  return result
}

//func !/<T: Mathable>(_ lhs: Vector<T>, _ rhs: BandMatrix<T>) -> (UpperBandMatrix<T>, LowerBandMatrix<T>) {
//  LUDecomposition(lhs, rhs)
//}
//
//fileprivate func LUDecomposition<T: Mathable>(_ lhs: Vector<T>, _ rhs: BandMatrix<T>) -> (UpperBandMatrix<T>, LowerBandMatrix<T>) {
//  fatalError()
//}

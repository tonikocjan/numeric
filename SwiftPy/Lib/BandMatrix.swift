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
  init(bandwidth: Int, height: Int) {
    upper = .init(bandwidth: bandwidth + 1, height: height)
    lower = .init(bandwidth: bandwidth, height: height - 1)
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
    func calculateBandwith(_ count: Int) -> Int {
      count == 1 ? 0 : Int(floor(Double(count) / 2))
    }
    
    let bandwitdh = calculateBandwith(elements.dropFirst().first?.count ?? elements[0].count)
    
    let bandwidth = calculateBandwith(elements.map { $0.count }.max(by: <)!)
    
    self.init(bandwidth: bandwidth, height: elements.count)
    for i in 0..<height {
      let offset = Swift.max(0, (height - bandwidth - (height - i)))
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
  
  // number of non-zero diagonals
  var bandwidth: Int { upper.bandwidth + lower.bandwidth }
  
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
    var matrix = BandMatrix(bandwidth: 0, height: size)
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
    let k = (lhs.bandwidth - 1) / 2
    let lower = Swift.max(0, i - (lhs.height - k) + 2)
    let upper = Swift.min(i + k + 1, lhs.height)
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

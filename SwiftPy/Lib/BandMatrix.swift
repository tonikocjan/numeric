//
//  TriangularMatrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 09/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

protocol BandMatrixProtocol: MatrixProtocol {
  var bandwidth: Int { get }
  var isDiagonalyDominant: Bool { get }
}

/// **Band** matrix
///
/// - Author: Toni K. Turk
///
/// In mathematics, particularly matrix theory, a band matrix is a sparse matrix whose non-zero entries are
/// confined to a diagonal band, comprising the main diagonal and zero or more diagonals on either side.
///
struct BandMatrix<T: Mathable>: BandMatrixProtocol {
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
    
//    func requiredNumberOfElements(in row: Int, k: Int, n: Int) -> Int {
//      let halfSize = Int(floor(Double(n) / 2)) - (n % 2 == 0 ? 1 : 0)
//      let x = halfSize - row
//      return Swift.max(1, (k * 2 + 1) - x * (x < 0 ? -1 : 1))
//    }
    
    let bandwidth = calculateBandwith(elements.map { $0.count }.max(by: <)!)
    
//    for (i, vec) in elements.enumerated() {
//      let required = requiredNumberOfElements(in: i, k: bandwidth, n: elements.count)
//      print(required)
//      if vec.count != required {
//        requiredNumberOfElements(in: i, k: bandwidth, n: elements.count)
//      }
//      assert(vec.count == requiredNumberOfElements(in: i, k: k, n: elements.count))
//    }

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
  
  var isDiagonalyDominant: Bool {
    guard bandwidth > 1 else { return true }
    for i in 0..<height {
      var sum: Value = 0
      for j in Swift.max(0, i - lower.bandwidth)..<Swift.min(width, i + upper.bandwidth) {
        if i == j { continue }
        sum += abs(self[i, j])
      }
      if sum > abs(self[i, i]) { return false}
    }
    return true
  }
  
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
  
  static func identity(_ size: Int) -> Self {
    var matrix = BandMatrix(bandwidth: 0, height: size)
    for i in 0..<size {
      matrix[i, i] = 1
    }
    return matrix
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
      (0..<height).forEach { self[i, $0] = newValue[$0] }
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
  let k = (lhs.bandwidth - 1) / 2
  for i in 0..<lhs.height {
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

extension BandMatrix {
  func LUDecomposition() -> (L: LowerBandMatrix<T>, U: UpperBandMatrix<T>) {
    let n = width
    
    var l = Vector<Value>(size: n - 1)
    var u = Vector<Value>(size: n)
    let u2 = (0..<(n-1)).map { self[$0, $0 + 1] }
    
    u[0] = self[0, 0]
    for k in 1..<n {
      l[k - 1] = self[k, k - 1] / u[k - 1]
      u[k] = self[k, k] - (self[k, k - 1] / u[k - 1]) * self[k - 1, k]
    }
    
    let lower = LowerBandMatrix(arrayLiteral: .ones(n), l)
    let upper = UpperBandMatrix(arrayLiteral: u, u2)
    
    return (lower, upper)
  }
}

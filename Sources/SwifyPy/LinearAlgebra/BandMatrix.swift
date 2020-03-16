//
//  TriangularMatrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 09/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

public protocol BandMatrixProtocol: MatrixProtocol {
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
public struct BandMatrix<T: Mathable>: BandMatrixProtocol {
  public typealias Value = T
  
  // upper matrix contains diagonal elements!
  var upper: UpperBandMatrix<T>
  var lower: LowerBandMatrix<T>
  
  /// Initialize a new **Band** matrix with specified size.
  ///
  /// - Parameter width: number of sub-diagonals with non-zero elements.
  ///                      - if width = 0 this is **diagonal** matrix
  ///                      - if width = 1 this is **tridiagonal** matrix
  ///                      - ...
  ///
  /// - Parameter height: height of the matrix
  ///
  public init(bandwidth: Int, height: Int) {
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
  public init(arrayLiteral elements: Vector<Value>...) {
    self.init(arrayLiteral: elements)
  }
  
  public init(arrayLiteral elements: [Vector<Value>]) {
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
public extension BandMatrix {
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
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.upper == rhs.upper && lhs.lower == rhs.lower
  }
}

// MARK: - Collection
extension BandMatrix: BidirectionalCollection {
  public subscript(_ i: Int) -> Vector<T> {
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
  public var debugDescription: String {
    "[" + map { $0.description }.joined(separator: "\n") + "]"
  }
}

// MARK: - CustomStringConvertible
extension BandMatrix: CustomStringConvertible where T: LosslessStringConvertible {
  public var description: String { debugDescription }
}

var BM_ITERATIONS_COUNT = 0 // for testing purposes

public func *<T: Mathable>(_ lhs: BandMatrix<T>, _ rhs: Vector<T>) -> Vector<T> {
  lhs.multiplty(with: rhs)
}

public func !/<T: Mathable>(_ lhs: Vector<T>, _ rhs: BandMatrix<T>) -> Vector<T> {
  rhs.leftDivision(with: lhs)
}

public func LUDecomposition<T: Mathable>(_ matrix: BandMatrix<T>) -> (L: LowerBandMatrix<T>, U: UpperBandMatrix<T>) {
  matrix.LUDecomposition()
}

extension BandMatrix {
  func multiplty(with rhs: Vec) -> Vec {
    assert(height == rhs.count)
    var result: Vector<T> = .zeros(height)
    BM_ITERATIONS_COUNT = 0
    for i in 0..<height {
      let lower = Swift.max(0, i - self.lower.bandwidth)
      let upper = Swift.min(i + self.upper.bandwidth, height)
      for j in lower..<upper {
        result[i] += self[i, j] * rhs[j]
        BM_ITERATIONS_COUNT += 1
      }
    }
    return result
  }
  
  func LUDecomposition() -> (L: LowerBandMatrix<T>, U: UpperBandMatrix<T>) {
    let n = width
    let lb = lower.bandwidth
    let ub = upper.bandwidth
    
    var upper = self.upper
    var lower = LowerBandMatrix<Value>(bandwidth: lb + 1, height: n)
    for i in 0..<n {
      for j in Swift.max(0, i - lb)...i {
        if i == j { lower[i, j] = 1; continue }
        lower[i, j] = self.lower[i - 1, j]
      }
    }
    
    func valueAt(_ i: Int, _ j: Int) -> Value {
      if i > j {
        return lower[i, j]
      }
      return upper[i, j]
    }
    
    func setValueAt(_ value: Value, _ i: Int, _ j: Int) {
      if i > j {
        lower[i, j] = value
        return
      }
      upper[i, j] = value
    }
    
    LU_ITERATIONS_COUNT = 0
    
    for k in 0..<n - 1 {
      for i in (k + 1)..<Swift.min(n, k + 1 + lb) {
        setValueAt(valueAt(i, k) / valueAt(k, k), i, k)
        for j in (k + 1)..<Swift.min(n, k + 1 + ub) {
          let val = valueAt(i, j) - valueAt(i, k) * valueAt(k, j)
          setValueAt(val, i, j)
          LU_ITERATIONS_COUNT += 1
        }
      }
    }
    
    return (L: lower, U: upper)
  }
  
  func leftDivision(with rhs: Vec) -> Vec {
    assert(rhs.count == self.width)
    
    let (L, U) = self.LUDecomposition()
    
    func valueAt(_ i: Int, _ j: Int) -> T {
      if i > j {
        return L[i, j]
      }
      return U[i, j]
    }
    
    let n = self.width

    var y = Vector<T>.ones(n)
    for i in 1..<n {
      var row = T.zero
      for j in Swift.max(0, i - lower.bandwidth)..<i {
        row += -valueAt(i, j) * y[j]
      }
      y[i] = row + rhs[i]
    }
    
    var x = Vector<T>.zeros(n)
    for i in stride(from: n - 1, to: -1, by: -1) {
      let from = Swift.min(n - 1, i + upper.bandwidth - 1)
      for j in stride(from: from, to: i, by: -1) {
        x[i] += -valueAt(i, j) * x[j]
      }
      x[i] = (y[i] + x[i]) / valueAt(i, i)
    }
    
    return x
  }
}

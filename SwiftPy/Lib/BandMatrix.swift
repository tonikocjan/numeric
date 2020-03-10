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
  private var storage: Matrix<T>
  let k: Int
  
  /// Initialize a new **Band** matrix with specified size.
  ///
  /// - Parameter width: number of sub-diagonals with non-zero diagonals.
  ///                      - if width = 0 this is **diagonal** matrix
  ///                      - if width = 1 this is **tridiagonal** matrix
  ///                      - ...
  ///
  /// - Parameter height: height of the matrix
  ///
  init(width: Int, height: Int) {
    self.k = width
    storage = Matrix(width: 1 + width * 2, height: height)
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
    assert(elements.count > 0) // TODO: - Can we construct an empty matrix?
    assert(elements.first!.count == elements.last!.count)
    let k = ((elements.dropFirst().first?.count ?? elements.first!.count) - 1) / 2
    for i in elements.dropFirst().dropLast() {
      assert(k == (i.count - 1) / 2)
    }
    self.k = k
    self.storage = Matrix(width: self.k * 2 + 1, height: elements.count)
    for i in 0..<storage.height {
      let isLast = i + 1 == height
      for j in 0..<storage.width {
        if i == 0 && j + 1 == width {
          storage[i, j] = 0
          continue
        }
        if isLast && j + 1 == width {
          storage[i, j] = 0
          continue
        }
        if j + 1 > elements[i].count {
          storage[i, j] = 0
          continue
        }
        storage[i, j] = elements[i][j]
      }
    }
  }
}


// MARK: - API
extension BandMatrix {
  var width: Int { storage.height }
  var height: Int { storage.height }
  var shape: (width: Int, height: Int) { (width, height) }
  
  subscript(_ i: Int, _ j: Int) -> T {
    get {
      assert(j >= 0)
      assert(j < width)
      let y = j - Swift.max(0, (height - k - (height - i)))
      if y < 0 { return .zero }
      if y >= storage.width { return .zero }
      return storage[i, y]
    }
    mutating set {
      assert(j >= 0)
      assert(j < width)
      let y = j - Swift.max(0, (height - k - (height - i)))
      if y < 0 {
        assert(newValue == 0)
        return
      }
      if y >= storage.width {
        assert(newValue == 0)
        return
      }
      storage[i, y] = newValue
    }
  }
  
  var transposed: Self {
    fatalError()
  }
  
  mutating func swap(row: Int, col: Int) {
    fatalError()
  }
  
  static func identity(_ size: Int) -> Self {
    var matrix = BandMatrix(width: 0, height: size)
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
    lhs.storage == rhs.storage
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

//
//  Matrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

/**
 # Matrix
 */
public struct Matrix<T: Mathable>: MatrixProtocol, Transposable {
  public typealias Value = T
  
  /// Implementation detail, not exposed to users.
  var storage: COWStorage<Vector<T>, (width: Int, height: Int)>
  
  /**
   Initialize a new matrix.
   
   Values in the matrix are not initialized to any default value, instead they are _random_.
   
   - Parameters:
       - width: Width of the matrix.
       - height: Height of the matrix.
   */
  public init(width: Int, height: Int) {
    self.storage = .init(capacity: height,
                         size: (width: width, height: height),
                         provider: Vector.init)
    for i in 0..<height {
      storage.buffer.advanced(by: i).initialize(to: .init(size: width))
    }
  }
  
  /**
   Initialize a new matrix from the given `elements`.
   
   Height of the matrix is `elements.count`.
   Width of the matrix is `elemenets.first?.count ?? 0`
   
   All vectors inside `elements` must have the same size.
   
   - Parameter elements: A list of vectors containing values from which this matrix will be initialized.
   */
  public init(arrayLiteral elements: [Vector<T>]) {
    let count = elements.first?.count ?? 0
    for el in elements.dropFirst() {
      assert(el.count == count)
    }
    self.storage = .init(elements: elements,
                         size: (width: elements.first?.count ?? 0, height: elements.count))
  }
  public init(arrayLiteral elements: Vector<T>...) {
    self.init(arrayLiteral: elements)
  }
}

// MARK: - DefaultValueInitializable
extension Matrix: DefaultValueInitializable {
  /**
   Initialize a new matrix and assign a default value to each element.
   
   - Parameters:
       - value: The default value for each element in the matrix.
       - width: Width of the matrix.
       - height: Height of the matrix.
   */
  public init(_ value: Value, width: Int, height: Int) {
    self.init(arrayLiteral: .init(repeating: .repeating(width, value: value),
                                  count: height))
  }
}

// MARK: - API
public extension Matrix {
  /// Width of the matrix (same as `height`).
  var width: Int { storage.size!.width }
  
  /// Height of the matrix.
  var height: Int { storage.size!.height }
  
  subscript(_ i: Int, _ j: Int) -> T {
    get {
      assert(i >= 0)
      assert(i < height)
      return self[i][j]
    }
    mutating set {
      assert(i >= 0)
      assert(i < height)
      self[i][j] = newValue
    }
  }
  
  /**
   Compute the `transpose` of this matrix.
   
   The transpose of a matrix is an operator which flips a matrix over its diagonal,
   that is it switches the row and column indices of the matrix by producing another matrix.
   
   Example:
   
       let matrix: Matrix = [
         [1, 4, 7],
         [2, 5, 8],
         [3, 6, 9]
       ]
       print(matrix.transposed)
       [[1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]]
   */
  var transposed: Self {
    var transposed = Matrix(width: height, height: width)
    for i in 0..<height {
      for j in 0..<width {
        transposed[j, i] = self[i, j]
      }
    }
    return transposed
  }
  
  /**
   Compute `identity` matrix with the given size.
   
   An identity matrix of size n is the n × n square matrix with ones on the main diagonal and zeros elsewhere.
   
   - Parameter size: Size of the matrix.
   
   - Returns: Identity matrix of the given size.
   */
  static func identity(_ size: Int) -> Self {
    (0..<size).map {
      var vec = Vector.zeros(size)
      vec[$0] = 1
      return vec
    }
  }
}

// MARK: - Equatable
extension Matrix: Equatable {
  /**
   Compare two matrices for equality.
  
   Matrices are equal when their shapes are equal and all their elements match.
  
   - Parameters:
       - lhs: First matrix.
       - rhs: Second matrix.
  
   - Returns: `true` if matrices are equal, `false` otherwise.
  */
  public static func == (lhs: Self, rhs: Self) -> Bool {
    guard lhs.shape == rhs.shape else { return false }
    return zip(lhs, rhs).allSatisfy(==)
  }
}

// MARK: - Collection
extension Matrix: BidirectionalCollection {
  public subscript(_ i: Int) -> Vector<T> {
    get {
      assert(i >= 0)
      assert(i < height)
      return storage.buffer[i]
    }
    mutating set {
      assert(i >= 0)
      assert(i < height)
      storageForWriting.buffer.advanced(by: i).initialize(to: newValue)
    }
  }
}

// MARK: - CustomDebugStringConvertible
extension Matrix: CustomDebugStringConvertible where Value: LosslessStringConvertible {
  public var debugDescription: String {
    "[" + map { $0.description }.joined(separator: "\n") + "]"
  }
}

// MARK: - CustomStringConvertible
extension Matrix: CustomStringConvertible where T: LosslessStringConvertible {
  public var description: String { debugDescription }
}

/// --------

// MARK: - SupportsCopyOnWrite
extension Matrix: SupportsCopyOnWrite {
  typealias Pointee = Vector<T>
  typealias U = (width: Int, height: Int)
}

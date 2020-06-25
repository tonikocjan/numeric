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
public struct Matrix<T: MatrixScalar>: MatrixProtocol, Transposable {
  public typealias Scalar = T
  
  /// Implementation detail, not exposed to users.
  var buffer: [Scalar]
  
  public let width: Int
  public let height: Int
  
  /**
   Initialize a new matrix.
   
   Values in the matrix are initialized to 0.
   
   - Parameters:
       - width: Width of the matrix.
       - height: Height of the matrix.
   */
  public init(width: Int, height: Int) {
    self.width = width
    self.height = height
    self.buffer = .init(repeating: 0, count: width * height)
  }
  
  /**
   Initialize a new matrix from the given list of values.
   
   - Parameters:
       - elements: A 1-D array containing values of this matrix.
       - width: Width of the matrix.
       - height: Height of the matrix.
   */
  public init(arrayLiteral elements: [Scalar], width: Int, height: Int) {
    self.width = width
    self.height = height
    self.buffer = elements
  }
  
  /**
   Initialize a new matrix from the given `elements`.
   
   Height of the matrix is `elements.count`.
   Width of the matrix is `elemenets.first?.count ?? 0`
   
   All vectors inside `elements` must have the same size.
   
   - Parameter elements: A list of vectors containing values from which this matrix will be initialized.
   */
  public init(arrayLiteral elements: [Vector<Scalar>]) {
    self.init(width: elements.first?.count ?? 0, height: elements.count)
    for (i, vec) in elements.enumerated() {
      for (j, v) in vec.enumerated() {
        self[i, j] = v
      }
    }
  }
  
  public init(arrayLiteral elements: Vector<Scalar>...) {
    self.init(arrayLiteral: elements)
  }
  
  /**
   Initialize a new matrix from the given list of values.
  
   - Parameter elements: A 2-D array containing values of this matrix.
   */
  public init(arrayLiteral elements: [[Scalar]]) {
    self.width = elements.first?.count ?? 0
    self.height = elements.count
    self.buffer = elements.flatMap { $0 }
  }
  
  /**
   Initialize a new matrix by copying values of another matrix.
   
   The new matrix is equivalent to the matrix being copied.
   
   - Parameter matrix: A matrix to be copied.
   */
  public init<M: MatrixProtocol>(_ matrix: M) where M.Scalar == Scalar {
    self.init(width: matrix.width, height: matrix.height)
    for i in 0..<width {
      for j in 0..<height {
        self[i, j] = matrix[i, j]
      }
    }
  }
  
  /**
   Initialize a new matrix by copying values of another matrix.
   
   The new matrix is equivalent to the matrix being copied.
   
   - Parameters matrix: A matrix to be copied.
   */
  public init(_ matrix: Matrix<Scalar>) {
    self.init(arrayLiteral: matrix.buffer, width: matrix.width, height: matrix.height)
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
  public init(_ value: Scalar, width: Int, height: Int) {
    self.init(arrayLiteral: .init(repeating: .repeating(width, value: value),
                                  count: height))
  }
}

// MARK: - API
public extension Matrix {
  subscript(_ i: Int, _ j: Int) -> T {
    get {
      assert(i >= 0)
      assert(i < height)
      return buffer[i * width + j]
    }
    mutating set {
      assert(i >= 0)
      assert(i < height)
      buffer[i * width + j] = newValue
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
    var matrix = Matrix(width: size, height: size)
    for i in 0..<size {
      matrix[i, i] = 1
    }
    return matrix
  }
  
  static func *(_ m1: Matrix, _ m2: Matrix) -> Matrix {
    Scalar.gemm(m1, m2)
  }
  
  static func *(_ m1: GivensMatrix<Scalar>, _ m2: Matrix) -> Matrix {
    Scalar.gemm(Matrix<Scalar>(arrayLiteral: m1.buffer, width: m1.width, height: m1.height), m2)
  }

//  @available(*, deprecated: "Much slower than above implementation!")
//  static func *(_ m1: GivensMatrix<Scalar>, _ m2: Matrix) -> Matrix {
//    assert(m1.width == m2.height)
//    assert(m1.height == m2.width)
//    let i = m1.i
//    let j = m1.j
//    var res = Matrix(m2)
//
//    for k in 0..<m2.height {
//      var a = Scalar.zero
//      var b = Scalar.zero
//
//      for l in 0..<m1.width {
//        a += m1[i, l] * m2[l, k]
//        b += m1[j, l] * m2[l, k]
//      }
//
//      res[i, k] = a
//      res[j, k] = b
//    }
//
//    return res
//  }
}

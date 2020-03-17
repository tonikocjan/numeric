//
//  MatrixProtocol.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 10/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

public typealias Mathable = FloatingPoint

/**
 An abstract definition of a matrix.
 */
public protocol MatrixProtocol: ExpressibleByArrayLiteral, Equatable, BidirectionalCollection where Element == Vector {
  /// Underlying type of values inside a matrix. It can be any type conforming to `FloatingPoint`.
  associatedtype Value: Mathable
  
  typealias Vector = SwifyPy.Vector<Value>
  
  /// Width of the matrix.
  var width: Int { get }
  
  /// Height of the matrix.
  var height: Int { get }
  
  /**
   Initialize a new matrix whose `height` will be equal to `elements.count` and width equal to `elements.first!.count`.
   It is required that all vectors inside `elemenets` have the same size.
   
   - Parameter elements: A list of vectors this matrix will be initialized to. `elements`'s components must all have the same size!
   
   - Returns: A new matrix containing the elements of provided vectors.
   */
  init(arrayLiteral elements: [Vector])
  init(arrayLiteral elements: Vector...)
  
  /**
   Access the element at the index (i, j).
   This is equivalent as subscripting first at index `ì` an then `j`.
   Both `i` and `j` must be valid indices otherwise the program will crash!
   
   Example:
   
       let m: (some) MatrixProtocol = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
       print(m[0, 0]) // 1
       print(m[2, 1]) // 8
   
   - Parameter:
       - i: Vertical offset (y-coordinate).
       - j: Horizontal offset (x-coordinate).
   */
  subscript(_ i: Int, _ j: Int) -> Value { get mutating set }
  
  /**
   Access the row at the given position.
   Index must be a valid index, i.e., greater than or equal to zero and less than height
   otherwise the program will crash!
   
   For instance:
   
       let m: (some) MatrixProtocol = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
       print(m[0]) // [1, 2, 3]
       print(m[2]) // [7, 8, 9]
   */
  subscript(_ i: Int) -> Vector { get mutating set }
  
  /**
   Computes `identity` matrix with the given size.
   
   An identity matrix of size n is the n × n square matrix with ones on the main diagonal and zeros elsewhere.
   
   - Parameter size: Size of the matrix.
   
   - Returns: Identity matrix of the given size.
   */
  static func identity(_ size: Int) -> Self
}

/// Default implementations for `BidirectionalCollection` conformance.
public extension MatrixProtocol {
  func index(after i: Int) -> Int { i + 1 }
  func index(before i: Int) -> Int { i - 1 }
  var startIndex: Int { 0 }
  var endIndex: Int { height }
  
  /// Useful overload which automatically converts a transformed list of vectors into a matrix.
  func map(_ transform: (Vector) throws -> Vector) rethrows -> Self {
    .init(arrayLiteral: try map(transform))
  }
}

// API
public extension MatrixProtocol {
  /**
   Shape of this matrix.
   
   - Returns: A shape of this matrix which is a tuple containing width and height of this matrix.
   */
  var shape: (width: Int, height: Int) { (width, height) }
  
  /**
   Origin point of any matrix.
   
   - Returns: (0, 0) if this matrix is not empty otherwise `nil`.
   */
  var firstIndex: (Int, Int)? { isEmpty ? nil : (0, 0) }
  
  /**
   Last valid index of this matrix
  
  - Returns: (width - 1, height - 1) if this matrix is not empty otherwise `nil`.
  */
  var lastIndex: (Int, Int)? { isEmpty ? nil : (height - 1, width - 1) }
}

/**
 Compare two matrices for equality.
 
 Matrices are equal when their shapes are equal and all their elements match.
 
 - Parameters:
     - lhs: First matrix.
     - rhs: Second matrix.
 
 - Returns: `true` if matrices are equal, `false` otherwise.
 */
public func == <M1: MatrixProtocol, M2: MatrixProtocol>(_ lhs: M1, _ rhs: M2) -> Bool where M1.Value == M2.Value {
  guard lhs.shape == rhs.shape else { return false }
  return zip(lhs, rhs).allSatisfy(==)
}

/// Math

/// Add a constant to all elements of a matrix.
public func +<M: MatrixProtocol>(_ m: M, _ val: M.Value) -> M {
  m.map { $0 + val }
}

/// Subtract a constant from all elements of a matrix.
public func -<M: MatrixProtocol>(_ m: M, _ val: M.Value) -> M {
  m.map { $0 - val }
}

/// Multiply a constant with all elements of a matrix.
public func *<M: MatrixProtocol>(_ m: M, _ val: M.Value) -> M {
  m.map { $0 * val }
}

/// Divide all elements of a matrix with a constant.
public func /<M: MatrixProtocol>(_ m: M, _ val: M.Value) -> M {
  m.map { $0 / val }
}

/// Add a constant to all elements of a matrix.
public func +<M: MatrixProtocol>(_ val: M.Value, _ m: M) -> M {
  m.map { $0 + val }
}

/// Subtract all elements of a matrix with from a constant.
public func -<M: MatrixProtocol>(_ val: M.Value, _ m: M) -> M {
  m.map { $0 - val }
}

/// Multiply a constant with all elements of a matrix.
public func *<M: MatrixProtocol>(_ val: M.Value, _ m: M) -> M {
  m.map { $0 * val }
}

/// Divide a constant with all elements of a matrix.
public func /<M: MatrixProtocol>(_ val: M.Value, _ m: M) -> M {
  m.map { $0 / val }
}

/// Element-wise matrix addition.
public func +<M: MatrixProtocol>(_ m1: M, _ m2: M) -> M {
  assert(m1.height == m2.height)
  assert(m1.width == m2.width)
  return zip(m1, m2).map { $0 + $1 }
}

/// Element-wise matrix addition.
public func -<M: MatrixProtocol>(_ m1: M, _ m2: M) -> M {
  assert(m1.height == m2.height)
  assert(m1.width == m2.width)
  return zip(m1, m2).map { $0 - $1 }
}

/**
 # Matrix-vector product.
 
 Multiplication between a matrix A and a vector x is defined as a `dot` product of all rows
 inside A with x.
 
 The height of the matrix must match the size of the vector.
 
 Example:
 
     let matrix: Matrix = [
       [1, 2, 3],
       [4, 5, 6],
       [7, 8, 9]
     ]
     let vector: Vector = [-2, 5, 1]
     print(matrix * vector) // [11, 23, 35]
 
 - Parameters:
     - A: A matrix.
     - x: A vector.
 
 - Returns: A vector whose elements are computed as a `dot` product of a row inside `A` with `x`.
 */
public func *<M: MatrixProtocol>(_ A: M, _ x: M.Vector) -> M.Vector {
  assert(A.height == x.count)
  return A.map { $0.dot(x) }
}

/**
 # Matrix-matrix product.
 
 For matrix multiplication, the number of columns in the first matrix must be equal
 to the number of rows in the second matrix.
 
 The result matrix, known as the matrix product, has the number of rows
 of the first and the number of columns of the second matrix.
 
 Example:
 
     let m1: Matrix = [
       [1, 2, 3],
       [4, 5, 6]
     ]
     let m2: Matrix = [
       [7, 8],
       [9, 10],
       [11, 12]
     ]
     print(m1 * m2) // [[58, 64], [139, 154]]
 
 - Parameters:
     - m1: First matrix.
     - m2: Second matrix.
 
 - Returns: Matrix product of two matrices.
 */
public func *<M: MatrixProtocol & Transposable>(_ m1: M, _ m2: M) -> Matrix<M.Value> {
  // multiplication implemented functionaly
  assert(m1.width == m2.height)
  assert(m1.height == m2.width)
  return m1.map { v1 in
    Vector(arrayLiteral: m2.columnMap { v1.dot($0) })
  }
}

public func *<M: MatrixProtocol>(_ m1: M, _ m2: M) -> Matrix<M.Value> {
  // multiplication implemented proceduraly
  assert(m1.width == m2.height)
  assert(m1.height == m2.width)
  var res = Matrix<M.Value>(width: m2.width, height: m1.height)
  for i in 0..<res.height {
    let row = m1[i]
    for j in 0..<m2.width {
      var sum = M.Value.zero
      for k in 0..<m2.height {
        sum += m2[k, j] * row[k]
      }
      res[i, j] = sum
    }
  }
  return res
}

infix operator !/: MultiplicationPrecedence

/**
 Solve linear system of equations.
 
 For detail explanation, refer to documentation for
 `func solveLinearSystem<M: MatrixProtocol>(_ A: M, _ b: M.Vector) -> M.Vector`
 inside `MatrixProtocol.swift`.
 
 - Paramaters:
     - b: Vector of constants.
     - A: Matrix of coefficients.
*/
public func !/<M: MatrixProtocol>(_ b: M.Vector, _ A: M) -> M.Vector {
  // solve linear system of equations
  solveLinearSystem(b, LUDecomposition(A))
}

/// -------

extension Zip2Sequence where Sequence1: MatrixProtocol, Sequence2: MatrixProtocol, Sequence1.Value == Sequence2.Value {
  public typealias Matrix = Sequence1
  public typealias Vec = Matrix.Vector
  
  public func map(_ transform: ((Vec, Vec)) throws -> Vec) rethrows -> Matrix {
    Matrix(arrayLiteral: try map(transform))
  }
}

extension Collection {
  public func map<T: Mathable>(_ transform: (Element) throws -> Vector<T>) rethrows -> Matrix<T> {
    Matrix(arrayLiteral: try map(transform))
  }
}

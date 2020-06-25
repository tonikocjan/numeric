//
//  MatrixProtocol.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 10/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

/**
 An abstract definition of a matrix.
 */
public protocol MatrixProtocol:
  ExpressibleByArrayLiteral,
  Equatable,
  BidirectionalCollection,
  CustomStringConvertible,
  CustomDebugStringConvertible,
  CustomReflectable
where Element == Vector
{
  /// Underlying type of values inside a matrix. It can be any type conforming to `FloatingPoint`.
  associatedtype Scalar: MatrixScalar
  
  typealias Vector = SwifyPy.Vector<Scalar>
  
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
  subscript(_ i: Int, _ j: Int) -> Scalar { get mutating set }
  
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
   Check whether this matrix is a square matrix.
   
   - Returns: `true` if `width` == `height`, `false` otherwise.
   */
  var isSquare: Bool {
    width == height
  }
  
  /**
   Origin point of any matrix.
   
   - Returns: (0, 0) if this matrix is not empty otherwise `nil`.
   */
  var firstIndex: (Int, Int)? { isEmpty ? nil : (0, 0) }
  
  /**
   Last valid index of this matrix
  
  - Returns: (width - 1, height - 1) if this matrix is not empty, `nil` otherwise.
  */
  var lastIndex: (Int, Int)? { isEmpty ? nil : (height - 1, width - 1) }
  
  /**
   Check whether this matrix is upper-tringular.
   
   Aa square matrix is called upper triangular if all the entries below the main diagonal are zero
   */
  var isUpperTriangular: Bool {
    guard isSquare else { return false }
    guard width > 1 else { return true }
    
    for i in 1..<height {
      for j in 0..<i {
        if self[i, j] > 10e-12 {
          return false
        }
      }
    }
    return true
  }
}

/**
 Compare two matrices for equality.
 
 Matrices are equal when their shapes are equal and all their elements match.
 
 - Parameters:
     - lhs: First matrix.
     - rhs: Second matrix.
 
 - Returns: `true` if matrices are equal, `false` otherwise.
 */
public func == <M1: MatrixProtocol, M2: MatrixProtocol>(_ lhs: M1, _ rhs: M2) -> Bool where M1.Scalar == M2.Scalar {
  lhs.shape == rhs.shape && zip(lhs, rhs).allSatisfy(==)
}

infix operator ~
public func ~<M1: MatrixProtocol, M2: MatrixProtocol>(_ lhs: M1, _ rhs: M2) -> Bool where M1.Scalar == M2.Scalar, M1.Scalar == Double {
  let accuracy = M1.Scalar(0.0001)
  for i in 0..<lhs.width {
    for j in 0..<lhs.width {
      if abs(lhs[i, j] - rhs[i, j]) > accuracy {
        return false
      }
    }
  }
  return true
}

// MARK: - Subscripts
public extension MatrixProtocol {
  subscript(_ i: Int) -> Vector {
    get {
      assert(i >= 0)
      assert(i < height)
      var vec = Vector(size: width)
      for j in 0..<width {
        vec[j] = self[i, j]
      }
      return vec
    }
    mutating set {
      assert(i >= 0)
      assert(i < height)
      for (j, v) in newValue.enumerated() {
        self[i, j] = v
      }
    }
  }
  
  subscript(_ indices: (Int, Int)) -> Scalar {
    get { self[indices.0, indices.1] }
    mutating set { self[indices.0, indices.1] = newValue }
  }
  
  subscript(range: Range<Int>, j: Int) -> Vector {
    get {
      assert(range.startIndex >= startIndex)
      assert(range.endIndex <= width)
      var vec = Vector(size: range.count)
      for (i, idx) in range.enumerated() {
        vec[i] = self[idx, j]
      }
      return vec
    }
    mutating set {
      assert(range.startIndex >= startIndex)
      assert(range.endIndex <= width)
      assert(newValue.count == range.count)
      for (i, idx) in range.enumerated() {
        self[idx, j] = newValue[i]
      }
    }
  }
  
  subscript(i: Int, range: Range<Int>) -> Vector {
    get {
      assert(range.startIndex >= startIndex)
      assert(range.endIndex <= height)
      var vec = Vector(size: range.count)
      for (j, idx) in range.enumerated() {
        vec[j] = self[i, idx]
      }
      return vec
    }
    mutating set {
      assert(range.startIndex >= startIndex)
      assert(range.endIndex <= height)
      assert(newValue.count == range.count)
      for (j, idx) in range.enumerated() {
        self[i, idx] = newValue[j]
      }
    }
  }
  
  subscript(range: ClosedRange<Int>, j: Int) -> Vector {
    get {
      self[Range(range), j]
    }
    mutating set {
      self[Range(range), j] = newValue
    }
  }
  
  subscript(i: Int, range: ClosedRange<Int>) -> Vector {
    get {
      self[i, Range(range)]
    }
    mutating set {
      self[i, Range(range)] = newValue
    }
  }
  
  subscript(i: Int, range: PartialRangeFrom<Int>) -> Vector {
    get {
      self[i, Range(uncheckedBounds: (range.lowerBound, width))]
    }
    mutating set {
      self[i, Range(uncheckedBounds: (range.lowerBound, width))] = newValue
    }
  }
  
  subscript(range: PartialRangeFrom<Int>, j: Int) -> Vector {
    get {
      self[Range(uncheckedBounds: (range.lowerBound, width)), j]
    }
    mutating set {
      self[Range(uncheckedBounds: (range.lowerBound, width)), j] = newValue
    }
  }
  
  subscript(i: Int, range: PartialRangeUpTo<Int>) -> Vector {
    get {
      self[i, Range(uncheckedBounds: (0, range.upperBound))]
    }
    mutating set {
      self[i, Range(uncheckedBounds: (0, range.upperBound))] = newValue
    }
  }
  
  subscript(range: PartialRangeUpTo<Int>, j: Int) -> Vector {
    get {
      self[Range(uncheckedBounds: (0, range.upperBound)), j]
    }
    mutating set {
      self[Range(uncheckedBounds: (0, range.upperBound)), j] = newValue
    }
  }
  
  subscript(i: Int, range: PartialRangeThrough<Int>) -> Vector {
    get {
      self[i, Range(uncheckedBounds: (0, range.upperBound))]
    }
    mutating set {
      self[i, Range(uncheckedBounds: (0, range.upperBound))] = newValue
    }
  }
  
  subscript(range: PartialRangeThrough<Int>, j: Int) -> Vector {
    get {
      self[Range(uncheckedBounds: (0, range.upperBound)), j]
    }
    mutating set {
      self[Range(uncheckedBounds: (0, range.upperBound)), j] = newValue
    }
  }
  
  ///
  
  subscript(horizontal: Range<Int>, vertical: Range<Int>) -> LazyMatrixView<Self> {
    get {
      .init(matrix: self, vertical: vertical, horizontal: horizontal)
    }
  }
  
  subscript(horizontal: ClosedRange<Int>, vertical: ClosedRange<Int>) -> LazyMatrixView<Self> {
    get {
      .init(matrix: self, vertical: vertical, horizontal: horizontal)
    }
  }
}

// MARK: - CustomDebugStringConvertible, CustomStringConvertible, CustomReflectable
public extension MatrixProtocol {
  var customMirror: Mirror {
    .init(self, children: [])
  }
  
  var debugDescription: String {
    "\(type(of: self))(\(width) * \(height))\n" + description
  }
  
  var description: String {
    "[" + map { $0.description }.joined(separator: ",\n ") + "]"
  }
}

/// Math

/// Add a constant to all elements of a matrix.
public func +<M: MatrixProtocol>(_ m: M, _ val: M.Scalar) -> M {
  m.map { $0 + val }
}

/// Subtract a constant from all elements of a matrix.
public func -<M: MatrixProtocol>(_ m: M, _ val: M.Scalar) -> M {
  m.map { $0 - val }
}

/// Multiply a constant with all elements of a matrix.
public func *<M: MatrixProtocol>(_ m: M, _ val: M.Scalar) -> M {
  m.map { $0 * val }
}

/// Divide all elements of a matrix with a constant.
public func /<M: MatrixProtocol>(_ m: M, _ val: M.Scalar) -> M {
  m.map { $0 / val }
}

/// Add a constant to all elements of a matrix.
public func +<M: MatrixProtocol>(_ val: M.Scalar, _ m: M) -> M {
  m.map { $0 + val }
}

/// Subtract all elements of a matrix with from a constant.
public func -<M: MatrixProtocol>(_ val: M.Scalar, _ m: M) -> M {
  m.map { $0 - val }
}

/// Multiply a constant with all elements of a matrix.
public func *<M: MatrixProtocol>(_ val: M.Scalar, _ m: M) -> M {
  m.map { $0 * val }
}

/// Divide a constant with all elements of a matrix.
public func /<M: MatrixProtocol>(_ val: M.Scalar, _ m: M) -> M {
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

public func sqrt<M: MatrixProtocol>(_ m: M) -> M {
  m.map { sqrt($0) }
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

extension Zip2Sequence where Sequence1: MatrixProtocol, Sequence2: MatrixProtocol, Sequence1.Scalar == Sequence2.Scalar {
  public typealias Matrix = Sequence1
  public typealias Vec = Matrix.Vector
  
  public func map(_ transform: ((Vec, Vec)) throws -> Vec) rethrows -> Matrix {
    Matrix(arrayLiteral: try map(transform))
  }
}

extension Collection {
  public func map<T: MatrixScalar>(_ transform: (Element) throws -> Vector<T>) rethrows -> Matrix<T> {
    Matrix(arrayLiteral: try map(transform))
  }
}

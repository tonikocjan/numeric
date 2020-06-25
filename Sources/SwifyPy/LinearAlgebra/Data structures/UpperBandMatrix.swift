//
//  UpperBandMatrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 10/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

/**
 # Upper Band Matrix
 
 In mathematics, an upper band matrix is a sparse matrix whose non-zero entries are
 confined to a diagonal band, comprising the main diagonal and zero or more diagonals above.
 
 It is a **square** matrix.
 */
public struct UpperBandMatrix<T: MatrixScalar>: BandMatrixProtocol {
  public typealias Scalar = T
  
  /// implementation details
  var buffer: [T]
  let size: Int
  
  /// Number of non-zero diagonals.
  public let bandwidth: Int
  
  /**
   Initialze a new **Upper band** matrix.
   
   - Parameters:
       - bandwidth: Number of bands, i.e., diagonalds containing non-zero elements. Must be greater than 0.
       - size: Size of the matrix.
   */
  public init(bandwidth: Int, size: Int) {
    assert(bandwidth >= 1)
    let bufferSize = stride(from: size, to: size - bandwidth, by: -1).reduce(0, +)
    self.buffer = .init(repeating: 0, count: bufferSize)
    self.size = size
    self.bandwidth = bandwidth
  }
  
  /**
   Initialize a new **Upper Band** matrix from the given `elements`.
   
   It is expected that provided vectors represent each non-zero diagonal.
  
   It is required that each vector in `elements` must be one element shorter than it's predecesor.
   
   The `bandwidth` of the new matrix is equal to `elements.count`.
   The size of the matrix is the size of the first vector in `elements`.
   
   Example:
       
       let matrix: UpperBandMatrix = [[1, 2, 3]]
       print(matrix)
       [[1, 0, 0],
        [0, 2, 0],
        [0, 0, 3]]
   
   Example:
   
       let matrix: UpperBandMatrix = [[1, 3, 5], [2, 4]]
       print(matrix)
       [[1, 2, 0],
        [0, 3, 4]
        [0, 0, 5]]]
   
   Example:
   
       let matrix: UpperBandMatrix = [[1, 3, 5, 7], [2, 4, 6]]
       print(matrix)
       [[1, 2, 0, 0],
        [0, 3, 4, 0],
        [0, 0, 5, 6],
        [0, 0, 0, 7]]
   
   - Parameter elements: A list of vectors containing values of all non-zero bands.
   */
  public init(arrayLiteral elements: [Vector<Scalar>]) {
    assert(elements.count > 0) // TODO: - Can we construct an empty matrix?
    for (i, el) in elements.dropFirst().enumerated() {
      assert(elements[i].count == el.count + 1)
    }
    
    self.init(bandwidth: elements.count, size: elements[0].count)
    var i = 0
    for el in elements {
      for e in el {
        buffer[i] = e
        i += 1
      }
    }
  }
  
  public init(arrayLiteral elements: Vector<Scalar>...) {
    self.init(arrayLiteral: elements)
  }
}

// MARK: - Equatable
extension UpperBandMatrix: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.shape == rhs.shape && lhs.buffer == rhs.buffer
  }
}

// MARK: - Public API
public extension UpperBandMatrix {
  /// Width of the matrix (same as `height`).
  var width: Int { size }
  
  /// Width of the matrix.
  var height: Int { size }
  
  /**
   Check if this matrix is _diagonally dominant_.
   
   A (square matrix) is said to be diagonally dominant if, for every row of the matrix, the magnitude
   of the diagonal entry in a row is larger than or equal to the sum of the magnitudes of all the other
   (non-diagonal) entries in that row.
   
   - Returns: `true` if matrix is diagonally dominant, `false` otherwise.
   */
  var isDiagonallyDominant: Bool {
    guard bandwidth > 1 else { return true }
    for i in 0..<height {
      var sum: Scalar = 0
      for j in (i + 1)..<Swift.min(i + bandwidth, width) {
        sum += abs(self[i, j])
      }
      if sum > abs(self[i, i]) { return false }
    }
    return true
  }
  
  /**
   Accesses the element at the index (i, j).
   This is equivalent as subscripting first at index `ì` an then `j`.
   Both `i` and `j` must be valid indices otherwise the program will crash!
   
   Example:
   
       let matrix: UpperBandMatrix = [[1, 2, 3]])
       print(matrix)
       [[1, 0, 0],
         [0, 2, 0],
         [0, 0, 3]]
       print(matrix[0, 0] // 1
       print(matrix[0, 1] // 0
       print(matrix[1, 0] // 0
   
   - Parameter:
       - i: Vertical offset (y-coordinate).
       - j: Horizontal offset (x-coordinate).
   */
  subscript(_ i: Int, _ j: Int) -> T {
    get {
      assert(i >= 0 && i < height)
      assert(j >= 0 && j < width)
      if i > j { return .zero }
      if j - i >= bandwidth { return .zero }
      return buffer[offset(i, j)]
    }
    mutating set {
      assert(i >= 0 && i < height)
      assert(j >= 0 && j < width)
      if i > j {
        assert(newValue == 0)
        return
      }
      if j - i >= bandwidth {
        assert(newValue == 0)
        return
      }
      buffer[offset(i, j)] = newValue
    }
  }
  
  private func offset(_ i: Int, _ j: Int) -> Int {
    let d = j - i
    let offset = ((d * size) - ((d * d - d) / 2)) + i
    return offset
  }
  
  /**
   Compute `identity` matrix with the given size.
   
   An identity matrix of size n is the n × n square matrix with ones on the main diagonal and zeros elsewhere.
   
   - Parameter size: Size of the matrix.
   
   - Returns: Identity matrix of the given size.
   */
  static func identity(_ size: Int) -> Self {
    .init(arrayLiteral: [.ones(size)])
  }
  
  /**
   Compute a vector containing all elements from a non-zero diagonal, distanced `index`
   from the main diagonal.
   
   - Parameter index: Index of the diagonal of interest.
   
   - Returns: A vector containing elements from the inquired diagonal. If `index == 0`, then
   the result is the main diagonal. `index` must be greater than zero.
   */
  func band(at index: Int) -> Vector<T> {
    assert(index >= 0)
    assert(index < bandwidth)
    var band = [T].init(repeating: 0, count: size - index)
    for (i, idx) in (index..<size).enumerated() {
      band[i] = self[i, idx]
    }
    return .init(arrayLiteral: band)
  }
}

var RBM_ITERATIONS_COUNT = 0 // for testing purposes

/**
 An optimized overload of the matrix-vector multiplication taking advantage of the fact
 that this is a sparse matrix.
 
 For a detailed explanation of matrix-vector multiplication refer to
 `public func *<M: MatrixProtocol>(_ A: M, _ x: M.Vector) -> M.Vector`
 overload inside `MatrixProtocol.swift`.
 
 - Parameters:
     - A: A matrix.
     - x: A vector.
 
 - Returns: A vector whose elements are computed as a `dot` product of each row inside `A` with `x`.
*/
public func *<T: MatrixScalar>(_ A: UpperBandMatrix<T>, _ x: Vector<T>) -> Vector<T> {
  assert(A.height == x.count)
  var result: Vector<T> = .zeros(A.height)
  RBM_ITERATIONS_COUNT = 0
  for i in 0..<A.height {
    for j in i..<Swift.min(i + A.bandwidth, A.height) {
      result[i] += A[i, j] * x[j]
      RBM_ITERATIONS_COUNT += 1
    }
  }
  return result
}

/**
 # Linear system of equations.

 Solve equation of form Ax = b where A is a matrix of coefficients of the system and b are the constant terms.

 - Parameters:
     - b: Vector containing constant terms.
     - A: Matrix containing coefficients of the system.

 - Returns: A vector `x` containing a solution (if it exists), such that Ax = b.
*/
public func !/<T: MatrixScalar>(_ b: Vector<T>, _ A: UpperBandMatrix<T>) -> Vector<T> {
  assert(b.count == A.width)
  return leftDivision(LUDecomposition(A), rhs: b)
}

/**
 # LU decomposition
 
 In numerical analysis and linear algebra, lower–upper (LU) decomposition or factorization factors a matrix
 as the product of a lower triangular matrix and an upper triangular matrix.
 LU decomposition can be viewed as the matrix form of Gaussian elimination. Square systems of linear equations are
 usually solved using LU decomposition by computers.
 
 - Parameter matrix: A matrix.
 
 - Returns: A tuple containing lower-triangular and upper-triangular matrix, such that A = LU.
 */
public func LUDecomposition<T: MatrixScalar>(_ matrix: UpperBandMatrix<T>) -> (L: LowerBandMatrix<T>, U: UpperBandMatrix<T>) {
  LU_ITERATIONS_COUNT = 0
  return (L: .identity(matrix.width), U: matrix)
}

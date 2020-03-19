//
//  LowerBandMatrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 10/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

/**
 # Lower Band Matrix

 In mathematics, a lower band matrix is a sparse matrix whose non-zero entries are
 confined to a diagonal band, comprising the main diagonal and zero or more diagonals below.

 It is a **square** matrix.
*/
public struct LowerBandMatrix<T: Mathable>: BandMatrixProtocol {
  public typealias Value = T
  
  var storage: COW
  
  /**
   Initialze a new **Lower band** matrix.
   
   - Parameters:
       - bandwidth: Number of bands, i.e., diagonalds containing non-zero elements. Must be greater than 0.
       - size: Size of the matrix.
   */
  public init(bandwidth: Int, size: Int) {
    assert(bandwidth >= 0) // TODO 
    storage = .init(capacity: bandwidth, size: size) { Vector(size: size - $0) }
  }
  
  /**
   Initialize a new **Lower Band** matrix from the given `elements`.
   
   It is expected that provided vectors represent each non-zero diagonal.
  
   It is required that each vector in `elements` must be one element shorter than it's predecesor.
   
   The `bandwithd` of the new matrix is equal to `elements.count`.
   The size of the matrix is the size of the first vector in `elements`.
   
   Example:
       
       let matrix: LowerBandMatrix = [[1, 2, 3]]
       print(matrix)
       [[1, 0, 0],
        [0, 2, 0],
        [0, 0, 3]]
   
   Example:
   
       let matrix: LowerBandMatrix = [[1, 3, 5], [2, 4]]
       print(matrix)
       [[1, 0, 0],
        [2, 3, 0]
        [0, 4, 5]]]
   
   Example:
   
       let matrix: LowerBandMatrix = [[1, 3, 5, 7], [2, 4, 6]]
       print(matrix)
       [[1, 0, 0, 0],
        [2, 3, 0, 0],
        [0, 4, 5, 0],
        [0, 0, 6, 7]]
   
   - Parameter elements: A list of vectors containing values of all non-zero bands.
   */
  public init(arrayLiteral elements: [Vector<Value>]) {
    assert(elements.count > 0) // TODO: - Can we construct an empty matrix?
    for (i, el) in elements.dropFirst().enumerated() {
      assert(elements[i].count == el.count + 1)
    }
    
    storage = .init(capacity: elements.count, size: elements[0].count) { elements[$0] }
  }
  
  public init(arrayLiteral elements: Vector<Value>...) {
    self.init(arrayLiteral: elements)
  }
}

// MARK: - Public API
public extension LowerBandMatrix {
  /// Width of the matrix (same as `height`).
  var width: Int { storage.size! }
  
  /// Width of the matrix.
  var height: Int { width }
  
  /// Number of non-zero diagonals.
  var bandwidth: Int { storage.capacity }
  
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
      var sum: Value = 0
      for j in stride(from: i - 1, to: Swift.max(i - bandwidth, 0), by: -1) {
        sum += self[i, j]
      }
      if sum > self[i, i] { return false }
    }
    return true
  }
  
  /**
   Accesses the element at the index (i, j).
   This is equivalent as subscripting first at index `ì` an then `j`.
   Both `i` and `j` must be valid indices otherwise the program will crash!
   
   Example:
   
        let matrix: LowerBandMatrix = [[1, 2, 3]])
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
      assert(j >= 0)
      assert(j < width)
      if j > i { return .zero }
      let diag = i - j
      if diag >= bandwidth { return .zero }
      return storage[diag][j]
    }
    mutating set {
      assert(j >= 0)
      assert(j < width)
      if j > i { return assert(newValue == 0) }
      if i - j >= bandwidth { return assert(newValue == 0) }
      storageForWriting[i - j][j] = newValue
    }
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
    return storage[index]
  }
}

// MARK: - Equatable
extension LowerBandMatrix: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.storage == rhs.storage
  }
}

// MARK: - Collection
extension LowerBandMatrix: BidirectionalCollection {
  public subscript(_ i: Int) -> Vector<T> {
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
extension LowerBandMatrix: CustomDebugStringConvertible where T: LosslessStringConvertible {
  public var debugDescription: String {
    "[" + map { $0.description }.joined(separator: "\n") + "]"
  }
}

// MARK: - CustomStringConvertible
extension LowerBandMatrix: CustomStringConvertible where T: LosslessStringConvertible {
  public var description: String { debugDescription }
}

var LBM_ITERATIONS_COUNT = 0 // for testing purposes

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
public func *<T: Mathable>(_ A: LowerBandMatrix<T>, _ x: Vector<T>) -> Vector<T> {
  assert(A.height == x.count)
  LBM_ITERATIONS_COUNT = 0
  var result: Vector<T> = .zeros(A.height)
  for i in 0..<A.height {
    for j in Swift.max(0, i - (A.height - A.bandwidth) + 1)...i {
      result[i] += A[i, j] * x[j]
      LBM_ITERATIONS_COUNT += 1
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
public func !/<T: Mathable>(_ b: Vector<T>, _ A: LowerBandMatrix<T>) -> Vector<T> {
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
public func LUDecomposition<T: Mathable>(_ matrix: LowerBandMatrix<T>) -> (L: LowerBandMatrix<T>, U: UpperBandMatrix<T>) {
  matrix.LUDecomposition()
}

/// Hidden implementation details.

/// This are optimized versions of the algorithms, taking advantage of the fact
/// that Band Matrix is a sparse matrix.
extension LowerBandMatrix {
  func LUDecomposition() -> (L: LowerBandMatrix<T>, U: UpperBandMatrix<T>) {
    let n = width
    var lower = self
    
    LU_ITERATIONS_COUNT = 0
    
    for k in 0..<n - 1 {
      for i in (k + 1)..<Swift.min(n, k + 1 + bandwidth) {
        lower[i, k] = lower[i, k] / lower[k, k]
        LU_ITERATIONS_COUNT += 1
      }
    }
    
    let mainDiag = lower.band(at: 0)
    
    let lowerVectors: [Vector] = (1..<bandwidth).map(lower.band)
    lower = LowerBandMatrix<Value>(arrayLiteral: [.ones(n)] + lowerVectors)
    
    return (L: lower, U: .init(arrayLiteral: mainDiag))
  }
}

/// --------

// MARK: - SupportsCopyOnWrite
extension LowerBandMatrix: SupportsCopyOnWrite {
  typealias Pointee = Vector<T>
  typealias U = Int
}

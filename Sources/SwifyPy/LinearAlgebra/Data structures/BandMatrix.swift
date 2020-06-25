//
//  BandMatrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 09/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

public protocol BandMatrixProtocol: MatrixProtocol {
  var bandwidth: Int { get }
  var isDiagonallyDominant: Bool { get }
  func band(at index: Int) -> Vector
}

/**
 # Band Matrix
 
 In mathematics, particularly matrix theory, a band matrix is a sparse matrix whose non-zero entries are
 confined to a diagonal band, comprising the main diagonal and zero or more diagonals on either side.
 
 It is a **square** matrix.
 */
public struct BandMatrix<T: MatrixScalar>: BandMatrixProtocol {
  public typealias Scalar = T
  
  /// upper matrix contains diagonal elements!
  var upper: UpperBandMatrix<T>
  var lower: LowerBandMatrix<T>

  /**
   Initialize a new **Band** matrix.
   
   - Parameters:
       - k: A factor representing number of diagonals with non-zero elements computed as `2 * k + 1`. For instance,
   when k = 0 this is a **diagonal** (`2 * 0 + 1 = 1`);
   when bandwitdh = 1 this is a **tridiagonal** matrix, and so on ...
       - size: Size of the matrix.
   */
  public init(k: Int, size: Int) {
    assert(k >= 0)
    upper = .init(bandwidth: k + 1, size: size)
    lower = .init(bandwidth: k, size: size - 1)
  }
  
  /**
   Initialize a new **Band** matrix.
   
   - Parameters:
       - k: Number of non-zero diagonals in the upper triangle of the matrix (including main diagonal).
       - l: Number of non-zero diagonals in the lower triangle of the matrix.
       - size: Size of the matrix.
   */
  public init(k: Int, l: Int, size: Int) {
    assert(k >= 0)
    upper = .init(bandwidth: k + 1, size: size)
    lower = .init(bandwidth: l, size: size - 1)
  }

  /**
   Initialize a new **Band** matrix from the given `elements`.
   
   The first and the lest vector in `elements` should have at least one item less
   than vectors in the middle, except when this is a diagonal matrix - all vectors must have size one.
   
   Example:
  
       let matrix: BandMatrix = [[1], [2], [3]])
       print(matrix)
       [[1, 0, 0],
        [0, 2, 0],
        [0, 0, 3]]
   
   Example:
   
       let matrix: BandMatrix = [[1, 2], [3, 4, 5], [6, 7]]
       [[1, 2, 0],
        [3, 4, 5],
        [0, 6, 7]]
   
   - Parameter elements: A list of vectors containing values from which this matrix will be initialized.
   */
  public init(arrayLiteral elements: [Vector<Scalar>]) {
    func calculateBandwith(_ count: Int) -> Int {
      count == 1 ? 0 : Int(floor(Double(count) / 2))
    }
    
    let bandwidth = calculateBandwith(elements.map { $0.count }.max(by: <)!)
   
    self.init(k: bandwidth, size: elements.count)
    for i in 0..<height {
      let offset = Swift.max(0, (height - bandwidth - (height - i)))
      for (j, el) in elements[i].enumerated() {
        self[i, j + offset] = el
      }
    }
  }
  
  public init(arrayLiteral elements: Vector<Scalar>...) {
    self.init(arrayLiteral: elements)
  }
  
  /**
   Initialize a new **Band** matrix where dieagonal values are given by `diagonals` dict.
   Keys in the `diagonals` represent the offset from the main diagonal, i.e. `0` is main diagonal,
   `-1` diagonal bellow main, `1` diagonal above main, ...
   
   Example:
   
       let m = BandMatrix<Double>(size: 9,
                                  diagonals: [0: .ones(9),
                                              1: .ones(8),
                                              -1: .ones(8)])
       print(m)
       [[1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, 0.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.0, 0.0],
        [0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.0],
        [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0],
        [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0]
       ]
   
   - Parameters `diagonals`: A dictionay containing non-zero diagonals.
   */
  public init(size: Int, diagonals: [Int: Vector<Scalar>]) {
    let ub = diagonals.max { $0.key < $1.key }!.key + 1
    let lb = -diagonals.min { $0.key < $1.key }!.key
    
    var upperDiagonals: [Vector<Scalar>] = []
    for i in 0..<ub {
      if let diag = diagonals[i] {
        assert(diag.count == size - i)
        upperDiagonals.append(diag)
      } else {
        upperDiagonals.append(.zeros(size - i))
      }
    }
    
    upper = .init(arrayLiteral: upperDiagonals)
    
    if lb > 0 {
      var lowerDiagonals: [Vector<Scalar>] = []
      for i in 1...lb {
        if let diag = diagonals[-i] {
          assert(diag.count == size - i)
          lowerDiagonals.append(diag)
        } else {
          lowerDiagonals.append(.zeros(size - i))
        }
      }
      lower = .init(arrayLiteral: lowerDiagonals)
    } else {
      lower = .init(bandwidth: 0, size: size - 1)
    }
  }
}

// MARK: - Public API
public extension BandMatrix {
  /// Width of the matrix (same as `height`).
  var width: Int { upper.height }
  
  /// Height of the matrix.
  var height: Int { upper.height }
  
  /// Number of non-zero diagonals.
  var bandwidth: Int { upper.bandwidth + lower.bandwidth }
  
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
      for j in Swift.max(0, i - lower.bandwidth)..<Swift.min(width, i + upper.bandwidth) {
        if i == j { continue }
        sum += abs(self[i, j])
      }
      if sum > abs(self[i, i]) { return false}
    }
    return true
  }
  
  /**
   Accesses the element at the index (i, j).
   This is equivalent as subscripting first at index `ì` an then `j`.
   Both `i` and `j` must be valid indices otherwise the program will crash!
   
   Example:
   
        let matrix: BandMatrix = [[1], [2], [3]])
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
  
  /**
   Compute `identity` matrix with the given size.
   
   An identity matrix of size n is the n × n square matrix with ones on the main diagonal and zeros elsewhere.
   
   - Parameter size: Size of the matrix.
   
   - Returns: Identity matrix of the given size.
   */
  static func identity(_ size: Int) -> Self {
    .init(arrayLiteral: .init(repeating: [1], count: size))
  }
  
  /**
   Compute a vector containing all elements from a non-zero diagonal, distanced `abs(index)`
   from the main diagonal.
   
   - Parameter index: Index of the diagonal of interest.
   
   - Returns: A vector containing elements from the inquired diagonal. If `index == 0`, then
   the result is the main diagonal. If `index < 0`, then the result is the diagonal `abs(index)`
   below from the main diagonal. If `index > 0`, then the result is the diagonal `index` above
   the main diagonal.
   */
  func band(at index: Int) -> Vector<T> {
    assert(abs(index) < bandwidth)
    let size = width - abs(index)
    let i = index < 0 ? 1 : 0
    let j = index > 0 ? 1 : 0
    return (0..<size).map { self[i + $0, j + $0] }
  }
}

// MARK: - Equatable
extension BandMatrix: Equatable {
  /**
  Compare two matrices for equality.
  
  Matrices are equal when their shapes are equal and all their elements match.
  
  - Parameters:
      - lhs: First matrix.
      - rhs: Second matrix.
  
  - Returns: `true` if matrices are equal, `false` otherwise.
  */
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.upper == rhs.upper && lhs.lower == rhs.lower
  }
}

var BM_ITERATIONS_COUNT = 0 // for testing purposes

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
public func *<T: MatrixScalar>(_ lhs: BandMatrix<T>, _ rhs: Vector<T>) -> Vector<T> {
  lhs.multiplty(with: rhs)
}

/**
 # Linear system of equations.

 Solve equation of form Ax = b where A is a matrix of coefficients of the system and b are the constant terms.
 
 Example:
 
     let A: BandMatrix = [
       [3, 2],
       [-4, 7, 8],
       [4, 13, 1],
       [5, 15]
     ]
     let b: Vector = [1, 2, 3, 4]
     print(y !/ A) // [0.1833, 0.2251, 0.1447, 0.2184]
 
 - Parameters:
     - b: Vector containing constant terms.
     - A: Matrix containing coefficients of the system.

 - Returns: A vector `x` containing a solution (if it exists), such that Ax = b.
*/
public func !/<T: MatrixScalar>(_ b: Vector<T>, _ A: BandMatrix<T>) -> Vector<T> {
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
public func LUDecomposition<T: MatrixScalar>(_ matrix: BandMatrix<T>) -> (L: LowerBandMatrix<T>, U: UpperBandMatrix<T>) {
  matrix.LUDecomposition()
}

/// --------

/// Hidden implementation details.

/// This are optimized versions of the algorithms, taking advantage of the fact
/// that Band Matrix is a sparse matrix.
extension BandMatrix {
  func multiplty(with rhs: Vector<Scalar>) -> Vector<Scalar> {
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
    let lowerVectors: [Vector] = (0..<lb).map(self.lower.band)
    var lower = LowerBandMatrix<Scalar>(arrayLiteral: [.ones(n)] + lowerVectors)
    
    func valueAt(_ i: Int, _ j: Int) -> Scalar {
      if i > j {
        return lower[i, j]
      }
      return upper[i, j]
    }
    
    func setValueAt(_ value: Scalar, _ i: Int, _ j: Int) {
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
}

func leftDivision<T: MatrixScalar>(_ decomposed: (LowerBandMatrix<T>, UpperBandMatrix<T>), rhs: Vector<T>) -> Vector<T> {
  let (L, U) = decomposed
  
  func valueAt(_ i: Int, _ j: Int) -> T {
    if i > j {
      return L[i, j]
    }
    return U[i, j]
  }
  
  let n = rhs.count

  var y = Vector<T>.ones(n)
  for i in 1..<n {
    var row = T.zero
    for j in Swift.max(0, i - L.bandwidth)..<i {
      row += -valueAt(i, j) * y[j]
    }
    y[i] = row + rhs[i]
  }
  
  var x = Vector<T>.zeros(n)
  for i in stride(from: n - 1, to: -1, by: -1) {
    let from = Swift.min(n - 1, i + U.bandwidth - 1)
    for j in stride(from: from, to: i, by: -1) {
      x[i] += -valueAt(i, j) * x[j]
    }
    x[i] = (y[i] + x[i]) / valueAt(i, i)
  }
  
  return x
}

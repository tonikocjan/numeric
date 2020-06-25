//
//  SymmetricBandMatrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 25/03/2020.
//

import Foundation

public struct SymmetricBandMatrix<T: MatrixScalar>: MatrixProtocol {
  public typealias Scalar = T

  var matrix: UpperBandMatrix<T>
  
  /**
   Initialize a new **Symmetric** band matrix.
   
   - Parameters:
       - bandwidth: Number of bands, i.e., diagonals containing non-zero elements, on the upper triangle
   including main diagonal.
       - width: Width (and height) of the matrix.
   */
  init(bandwidth: Int, width: Int) {
    assert(bandwidth >= 0 && bandwidth <= width)
    matrix = .init(bandwidth: bandwidth, size: width)
  }
  
  /**
   Initialize a new **Symmetric** band matrix from the given `elements`.
   
   It is expected that provided vectors represent each non-zero diagonal.
  
   It is required that each vector in `elements` must be one element shorter than it's predecesor.
   
   The `bandwidth` of the new matrix is equal to `elements.count * 2 - 1`.
   The size of the matrix is the size of the first vector in `elements`.
   
   Example:
       
       let matrix: SymmetricBandMatrix = [[1, 2, 3]]
       1> print(matrix)
       [[1, 0, 0],
        [0, 2, 0],
        [0, 0, 3]]
   
   Example:
   
       let matrix: SymmetricBandMatrix = [[1, 3, 5], [2, 4]]
       1> print(matrix)
       [[1, 2, 0],
        [2, 3, 4]
        [0, 4, 5]]]
   
   Example:
   
       let matrix: SymmetricBandMatrix = [[1, 3, 5, 7], [2, 4, 6]]
       1> print(matrix)
       [[1, 2, 0, 0],
        [2, 3, 4, 0],
        [0, 4, 5, 6],
        [0, 0, 6, 7]]
   
   - Parameter elements: A list of vectors containing values of all non-zero bands.
   */
  public init(arrayLiteral elements: [Vector<Scalar>]) {
    matrix = .init(arrayLiteral: elements)
  }
  
  public init(arrayLiteral elements: Vector<Scalar>...) {
    matrix = .init(arrayLiteral: elements)
  }
  
  /**
   Initialze a new **Symmetric** band matrix from the given upper band matrix.
   */
  public init(_ matrix: UpperBandMatrix<Scalar>) {
    self.matrix = matrix
  }
  
  public init(_ matrix: Matrix<Scalar>) {
    assert(matrix.isSymmetric)
    self.matrix = .init(bandwidth: matrix.width, size: matrix.width)
    for i in 0..<width {
      for j in i..<width {
        self[i, j] = matrix[i, j]
      }
    }
  }
}

// MARK: - Public API
public extension SymmetricBandMatrix {
  var width: Int { matrix.width }
  var height: Int { matrix.height }
  var bandwidth: Int { matrix.bandwidth }
  
  static func identity(_ size: Int) -> SymmetricBandMatrix<T> {
    .init(UpperBandMatrix.identity(size))
  }
  
  subscript(i: Int, j: Int) -> T {
    get {
      assert(i >= 0 && i < height)
      assert(j >= 0 && j < width)
      if j >= i {
        return matrix[i, j]
      }
      return matrix[j, i]
    }
    mutating set {
      assert(i >= 0 && i < height)
      assert(j >= 0 && j < width)
      if j >= i {
        matrix[i, j] = newValue
        return
      }
      matrix[j, i] = newValue
    }
  }
}

//
//  SymTridiagonalMatrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 25/03/2020.
//

import Foundation

/**
 # Symmetric tridiagonal matrix.
 */
public struct SymTridiagonalMatrix<T: MatrixScalar>: MatrixProtocol {
  public typealias Scalar = T
  
  /// implementation details
  var matrix: SymmetricBandMatrix<T>
  
  /**
   Initialize a new **Symmetric tridiagonal** matrix of the given size.
   
   - Parameter width: Width (and height) of the matrix.
   */
  public init(width: Int) {
    matrix = .init(bandwidth: Swift.min(width, 2), width: width)
  }
  
  /**
   Initialize a new **Symmetric tridiagonal** matrix from the given `elements`.
   
   Example:
   
       var matrix: SymTridiagonalMatrix = [[1, 2, 3]]
       1> print(matrix)
       [[1, 0, 0],
        [0, 2, 0],
        [0, 0, 3]]
   
   Example:
   
       var matrix: SymTridiagonalMatrix = [[1, 3, 5], [2, 4]]
       1> print(matrix)
       [[1, 2, 0],
        [2, 3, 4],
        [0, 4, 5]]
   
   - Parameter elements: Values for the main and co-main diagonal. `elements.count` must be 2 or less!
   */
  public init(arrayLiteral elements: [Vector<T>]) {
    assert(elements.count > 0 && elements.count <= 2)
    matrix = .init(arrayLiteral: elements)
  }
  
  public init(arrayLiteral elements: Vector<T>...) {
    self.init(arrayLiteral: elements)
  }
  
  /**
   Initialze a new **Symmetric tridiagonal** matrix by copying values of another matrix.
   
   Not that only the values on the main and upper co-main diagonal will get copied.
   
   - Parameter matrix: A matrix whose values will get copied.
   */
  public init<M: MatrixProtocol>(_ matrix: M) where M.Scalar == Scalar {
    assert(matrix.width == matrix.height)
    self.init(width: matrix.width)
    for i in 0..<matrix.width - 1 {
      self[i, i] = matrix[i, i]
      self[i, i + 1] = matrix[i, i + 1]
    }
    self[lastIndex!] = matrix[lastIndex!]
  }
}

// MARK: - Public API
public extension SymTridiagonalMatrix {
  var width: Int { matrix.width }
  var height: Int { matrix.height }
  
  static func identity(_ size: Int) -> SymTridiagonalMatrix<T> {
    .init(arrayLiteral: .ones(size))
  }
  
  subscript(i: Int, j: Int) -> T {
    get {
      matrix[i, j]
    }
    set {
      matrix[i, j] = newValue
    }
  }
}


//
//  LazyMatrixView.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 27/03/2020.
//

import Foundation

/**
 # LazyMatrixView.
 
 The `LazyMatrixView` type makes it fast and efficient to perform
 operations on sections of a bigger matrix. Instead of copying over the
 elements of the matrix to new storage, a `LazyMatrixView` instance presents a
 view onto the storage of a larger matrix. And because `LazyMatrixView`
 conforms to `MatrixProtocol`, you can generally perform the
 same operations on a view as you could on the original matrix.
 */
public struct LazyMatrixView<M: MatrixProtocol>: MatrixProtocol {
  public typealias Scalar = M.Scalar
  typealias Range = Swift.Range<Int>
  typealias ClosedRange = Swift.ClosedRange<Int>
  
  var matrix: M
  let vertical: Range
  let horizontal: Range
  
  init(matrix: M, vertical: Range, horizontal: Range) {
    assert(horizontal.startIndex >= 0 && horizontal.endIndex <= matrix.width)
    assert(vertical.startIndex >= 0 && vertical.endIndex <= matrix.height)
    self.matrix = matrix
    self.vertical = vertical
    self.horizontal = horizontal
  }
  
  init(matrix: M, vertical: ClosedRange, horizontal: ClosedRange) {
    self.init(matrix: matrix, vertical: Range(vertical), horizontal: Range(horizontal))
  }
  
  public init(arrayLiteral elements: Vector<Scalar>...) {
    self.init(arrayLiteral: elements)
  }
  
  public init(arrayLiteral elements: [Vector<Scalar>]) {
    matrix = .init(arrayLiteral: elements)
    vertical = .init(uncheckedBounds: (lower: 0, upper: matrix.height))
    horizontal = .init(uncheckedBounds: (lower: 0, upper: matrix.width))
  }
}

public extension LazyMatrixView {
  var width: Int { horizontal.count }
  var height: Int { vertical.count }
  
  static func identity(_ size: Int) -> LazyMatrixView<M> {
    fatalError()
  }
  
  subscript(i: Int, j: Int) -> Scalar {
    get {
      assert(i >= 0 && i < height)
      assert(j >= 0 && j < width)
      return matrix[i + vertical.startIndex, j + horizontal.startIndex]
    }
    mutating set {
      assert(i >= 0 && i < height)
      assert(j >= 0 && j < width)
      matrix[i + vertical.startIndex, j + horizontal.startIndex] = newValue
    }
  }
}

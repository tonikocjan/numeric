//
//  GivensMatrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 26/03/2020.
//

import Foundation

/**
 # Givens rotation matrix.
 
 https://en.wikipedia.org/wiki/Givens_rotation
 */
public struct GivensMatrix<T: MatrixScalar>: MatrixProtocol {
  public typealias Scalar = T
  
  let i: Int
  let j: Int
  let c: T
  let s: T
  public let width: Int
  public var height: Int { width }
  
  // We sacrifice space to gain ~7x faster `QRDecomposition`!
  var buffer: [T]
  
  /**
   Initialize a new **Givens** rotation matrix.
  
   - Parameters:
       - i: Location of `c`.
       - j: Location of `s`.
       - c: Cosine theta.
       - s: Sine theta.
       - size: Width and height of the matrix.
  
   - Returns: Givens matrix G(i, j, theta).
  */
  init(i: Int, j: Int, c: T, s: T, size: Int) {
    self.i = i
    self.j = j
    self.c = c
    self.s = s
    self.width = size
    self.buffer = .init(repeating: 0, count: size * size)
    buffer[i * width + j] = -s
    buffer[j * width + i] = s
    for k in 0..<size {
      buffer[k * width + k] = 1
    }
    buffer[i * width + i] = c
    buffer[j * width + j] = c
  }
  
  public init(arrayLiteral elements: [Vector<T>]) {
    fatalError()
  }
  
  public init(arrayLiteral elements: Vector<T>...) {
    fatalError()
  }
}

// MARK: - Public API
public extension GivensMatrix {
  subscript(i: Int, j: Int) -> Scalar {
    get {
      assert(i < height)
      assert(i >= 0)
      assert(j < width)
      assert(j >= 0)
      return buffer[i * width + j]
    }
    set {
      fatalError()
    }
  }
  
  subscript(i: Int) -> Vector<T> {
    get {
      assert(i < height)
      assert(i >= 0)
      var vec = Vector(size: width)
      for j in 0..<width { vec[j] = self[i, j] }
      return vec
    }
    set { fatalError("Givens matrix is immutable!") }
  }
  
  static func identity(_ size: Int) -> GivensMatrix<T> {
    .init(i: -1, j: -1, c: 0, s: 0, size: size)
  }
}

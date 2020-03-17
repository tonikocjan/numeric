//
//  Transposable.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 16/03/2020.
//

import Foundation

/**
 # Transposable
 
 The transpose of a matrix is an operator which flips
 a matrix over its diagonal, that is it switches the row and column indices
 of the matrix by producing another matrix.
 
 Even though every matrix can be transposed, we provide a separate protocol.
 Our reasoning is that some data structures, like sparse matrices (BandMatrix, ...),
 cannot provide a `transposed` version of themselves. Therefore, only _some_ matrices can
 conform to this protocol.
 
 We might consider implementing this differently, by instead allowing `transposed` to be
 any MatrixProtocol:
 
     public protocol Transposable {
       associatedType M: MatrixProtocol
       /// Compute the transpose of this matrix.
       var transposed: M { get }
     }
 */
public protocol Transposable {
  /// Compute the transpose of this matrix.
  var transposed: Self { get }
}

/**
 Beside row-wise collection operations (map, filter, reduce), every `Transposable` matrix also
 has column-wise operations.
 */
public extension MatrixProtocol where Self: Transposable {
  func columnMap<T>(_ transform: (Vector) throws -> T) rethrows -> [T] {
    try transposed.map(transform)
  }

  func columnMap(_ transform: (Vector) throws -> Vector) rethrows -> Self {
    .init(arrayLiteral: try columnMap(transform))
  }

  func columnFilter(_ predicate: (Vector) throws -> Bool) rethrows -> [Vector] {
    try columnMap { $0 }.filter(predicate)
  }

  func columnFilter(_ predicate: (Vector) throws -> Bool) rethrows -> Self {
    .init(arrayLiteral: try columnMap { $0 }.filter(predicate))
  }

  func columnReduce<Result>(_ initialResult: Result, nextPartialResult: (Result, Vector) throws -> Result) rethrows -> Result {
    try transposed.reduce(initialResult, nextPartialResult)
  }
}

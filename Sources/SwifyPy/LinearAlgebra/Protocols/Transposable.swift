//
//  Transposable.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 16/03/2020.
//

import Foundation

public protocol Transposable {
  var transposed: Self { get }
}

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

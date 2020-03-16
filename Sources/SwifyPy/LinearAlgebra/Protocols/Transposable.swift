//
//  Transposable.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 16/03/2020.
//

import Foundation

protocol Transposable {
  var transposed: Self { get }
}

extension MatrixProtocol where Self: Transposable {
  func columnMap<T>(_ transform: (Vec) throws -> T) rethrows -> [T] {
    try transposed.map(transform)
  }

  func columnMap(_ transform: (Vec) throws -> Vec) rethrows -> Self {
    .init(arrayLiteral: try columnMap(transform))
  }

  func columnFilter(_ predicate: (Vec) throws -> Bool) rethrows -> [Vec] {
    try columnMap { $0 }.filter(predicate)
  }

  func columnFilter(_ predicate: (Vec) throws -> Bool) rethrows -> Self {
    .init(arrayLiteral: try columnMap { $0 }.filter(predicate))
  }

  func columnReduce<Result>(_ initialResult: Result, nextPartialResult: (Result, Vec) throws -> Result) rethrows -> Result {
    try transposed.reduce(initialResult, nextPartialResult)
  }
}

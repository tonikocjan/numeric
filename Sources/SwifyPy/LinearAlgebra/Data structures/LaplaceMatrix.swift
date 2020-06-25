//
//  LaplaceMatrix.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 28/03/2020.
//

import Foundation

public struct LaplaceMatrix /*: MatrixProtocol*/ {
  let graph: [[Int]]
  
  public init(graph: [[Int]]) {
    self.graph = graph
  }
}

public extension LaplaceMatrix {
  var width: Int { graph.count }
  var height: Int { graph.count }
  var shape: (width: Int, height: Int) { (width, height) }
}

public func *<T: MatrixScalar>(_ lhs: LaplaceMatrix, _ rhs: Vector<T>) -> Vector<T> {
  var y = rhs
  for i in 0..<rhs.count {
    y[i] = T(lhs.graph[i].count) * rhs[i]
    y[i] -= lhs.graph[i].reduce(T.zero) { (acc, next) in acc + rhs[next] }
  }
  return y
}

public func *<M: MatrixProtocol>(_ lhs: LaplaceMatrix, _ rhs: M) -> Matrix<M.Scalar> {
  assert(lhs.shape == rhs.shape)
  var y = Matrix<M.Scalar>(rhs)
  for i in 0..<rhs.height {
    let minus = lhs.graph[i]
      .map { rhs[$0] }
      .reduce(Vector<M.Scalar>(size: lhs.width)) { $0 + $1 }
    for j in 0..<rhs.width {
      y[i, j] = M.Scalar(lhs.graph[i].count) * rhs[i, j]
      y[i, j] -= minus[j]
    }
  }
  return y
}

//
//  _solve.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

func argmax<T: Mathable>(_ v: Vector<T>, from: Int = 0) -> Int {
  assert(from < v.count)
  assert(from >= 0)
  var idx = from
  var max = v[from]
  for i in (1..<v.count) {
    if max < v[i] {
      idx = i
      max = v[i]
    }
  }
  return idx
}

func gaussElimination<M: MatrixProtocol>(_ a: M) -> M {
  assert(a.width == a.height)
  
  let n = a.width
  var U = a

  for k in 0..<(n - 1) {
    for i in (k + 1)..<n {
      let l = U[i, k] / U[k, k]
      for j in (k+1)..<n {
        U[i, j] = U[i, j] - l * U[k, j]
      }
    }
  }
  return U
}

func LUDecomposition<M: MatrixProtocol>(_ a: M, _ v: Vector<M.Value>) -> Vector<M.Value> {
  assert(a.width == a.height)
  
  let n = a.width
  var A = a
  
  for k in 0..<(n - 1) {
    for i in (k + 1)..<n {
      A[i, k] = A[i, k] / A[k, k]
      for j in (k + 1)..<n {
        A[i, j] = A[i, j] - A[i, k] * A[k, j]
      }
    }
  }
  
  return v
}

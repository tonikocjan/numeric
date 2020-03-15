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

func solveLinearSystem<M: MatrixProtocol>(_ A: M, _ v: M.Vec) -> M.Vec {
  // `A` must be a LU decomposed matrix
  assert(A.width == A.height)
  assert(A.width == v.count)
  
  let n = A.width

  var y = M.Vec.ones(n)
  for i in 1..<n {
    var row = M.Value.zero
    for j in 0..<i {
      row += -A[i, j] * y[j]
    }
    y[i] = row + v[i]
  }
  
  var x = M.Vec.zeros(n)
  for i in stride(from: n - 1, to: -1, by: -1) {
    for j in stride(from: n - 1, to: i, by: -1) {
      x[i] += -A[i, j] * x[j]
    }
    x[i] = (y[i] + x[i]) / A[i, i]
  }
  
  return x
}

var LU_ITERATIONS_COUNT = 0

func LUDecomposition<M: MatrixProtocol>(_ a: M) -> M {
  assert(a.width == a.height)
  
  let n = a.width
  var A = a
  
  LU_ITERATIONS_COUNT = 0
  for k in 0..<(n - 1) {
    for i in (k + 1)..<n {
      A[i, k] = A[i, k] / A[k, k]
      for j in (k + 1)..<n {
        A[i, j] = A[i, j] - A[i, k] * A[k, j]
        LU_ITERATIONS_COUNT += 1
      }
    }
  }
  
  return A
}


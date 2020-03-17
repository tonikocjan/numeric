//
//  _solve.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

/**
 Perform a gaussian elimination on a matrix without pivoting.
 
 Gaussian elimination, also known as row reduction, is an algorithm in linear algebra for
 solving a system of linear equations. It is usually understood as a sequence of operations
 performed on the corresponding matrix of coefficients.
 
 - Parameter A: Matrix of coefficients of the system.
 
 - Returns: A matrix in a row echelon form.
 */
func gaussElimination<M: MatrixProtocol>(_ A: M) -> M {
  assert(A.width == A.height)
  
  let n = A.width
  var U = A

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

func solveLinearSystem<M: MatrixProtocol>(_ A: M, _ v: M.Vector) -> M.Vector {
  // `A` must be a LU decomposed matrix
  assert(A.width == A.height)
  assert(A.width == v.count)
  
  let n = A.width

  var y = M.Vector.ones(n)
  for i in 1..<n {
    var row = M.Value.zero
    for j in 0..<i {
      row += -A[i, j] * y[j]
    }
    y[i] = row + v[i]
  }
  
  var x = M.Vector.zeros(n)
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

/**
 # Linear system of equations.

 Solve equation of form Ax = b where A is a matrix of coefficients of the system and b are the constant terms.
 
 Example:
 
     let A: BandMatrix = [
       [3, 2],
       [-4, 7, 8],
       [4, 13, 1],
       [5, 15]
     ]
     let b: Vector = [1, 2, 3, 4]
     print(y !/ A) // [0.1833, 0.2251, 0.1447, 0.2184]
 
 - Parameters:
     - b: Vector containing constant terms.
     - A: LU decomposed matrix, where L is lower-triangular matrix and U upper-triangular matrix such that A = LU.

 - Returns: A vector `x` containing a solution (if it exists), such that Ax = b.
*/
func solveLinearSystem<M: MatrixProtocol>(_ b: M.Vector, _ A: M) -> M.Vector {
  assert(A.width == A.height)
  assert(A.width == b.count)
  
  let n = A.width

  var y = M.Vector.ones(n)
  for i in 1..<n {
    var row = M.Value.zero
    for j in 0..<i {
      row += -A[i, j] * y[j]
    }
    y[i] = row + b[i]
  }
  
  var x = M.Vector.zeros(n)
  for i in stride(from: n - 1, to: -1, by: -1) {
    for j in stride(from: n - 1, to: i, by: -1) {
      x[i] += -A[i, j] * x[j]
    }
    x[i] = (y[i] + x[i]) / A[i, i]
  }
  
  return x
}

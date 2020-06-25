//
//  QRDecomposition.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 24/03/2020.
//

import Foundation

/**
 Compute QR decomposition of A such that `A = Q * R` using givens rotations.
 https://en.wikipedia.org/wiki/QR_decomposition#Using_Givens_rotations
 
 - Paramater A: Matrix to decompose.
 - Returns: QR decomposed matrix such that `Q * R = A`.
 */
public func QRDecomposition<M: MatrixProtocol>(_ A: M) -> (Q: Matrix<M.Scalar>, R: Matrix<M.Scalar>) {
  assert(A.width == A.height)

  var R = Matrix(A)
  var Q = Matrix<M.Scalar>.identity(A.width)

  for i in 0..<R.width - 1 {
    for j in stride(from: R.width - 1, to: i, by: -1) {
      let a = R[i, i]
      let b = R[j, i]
      let (c, s, _) = givens(a: a, b: b)
      
      let G = GivensMatrix(i: i, j: j, c: c, s: s, size: A.width)
      Q = G * Q
      R = G * R
    }
  }

  return (Q.transposed, R)
}

/**
 Compute QR decomposition of A such that `A = Q * R` using givens rotations.
 https://en.wikipedia.org/wiki/QR_decomposition#Using_Givens_rotations
 
 - Paramater A: A symmetric tridiagonal matrix to decompose.
 - Returns: QR decomposed matrix such that `Q * R = A`.
 */
public func QRDecomposition<T: MatrixScalar>(_ A: SymTridiagonalMatrix<T>) -> (Q: Matrix<T>, R: Matrix<T>) {
  assert(A.width == A.height)

  var R = Matrix(A)
  var Q = Matrix<T>.identity(A.width)

  for i in 0..<R.width - 1 {
    let j = i + 1

    let a = R[i, i]
    let b = R[j, i]
    let (c, s, _) = givens(a: a, b: b)
    
    let G = GivensMatrix(i: i, j: j, c: c, s: s, size: A.width)
    Q = G * Q
    R = G * R
  }
  return (Q.transposed, R)
}

func givens<T: MatrixScalar>(a: T, b: T) -> (c: T, s: T, p: T) {
  if b == 0 {
    return (1, 0, 0)
  }
  if a == 0 {
    return (0, 1, 1)
  }
  if abs(b) > abs(a) {
    let r = -a / b
    let s = 1 / sqrt(1 + r * r)
    let c = s * r
    return (c, s, 2.0 / c)
  }
  let r = -b / a
  let c = 1 / sqrt(1 + r * r)
  let s = c * r
  return (c, s, s / 2.0)
}

func givensInv<T: MatrixScalar>(p: T) -> (c: T, s: T) {
  if p == 0 {
    return (1, 0)
  }
  if p == 1 {
    return (0, 1)
  }
  if abs(p) > 2 {
    let c = 2 / p
    let s = sqrt(1 - c * c)
    return (c, s)
  }
  let s = 2 / p
  let c = sqrt(1 - s * s)
  return (c, s)
}

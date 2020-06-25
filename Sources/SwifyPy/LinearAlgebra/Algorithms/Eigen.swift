//
//  Eigen.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 28/03/2020.
//

import Foundation
import PythonKit

/**
 Compute eigenvalues (and vectors) of the given matrix using `QR algorithm`.
 
 In linear algebra, an eigenvector of a linear transformation is a nonzero vector
 that changes at most by a scalar factor when that linear transformation is applied to it.
 The corresponding eigenvalue is the factor by which the eigenvector is scaled.
 
 In mathematical terms, we are solving the equation
 
     Ax = λx
 
 where `x` is an eigenvector and `λ` an eigenvalue.
 
 - Parameters:
     - A: A matrix representing a linear transformation whose eigenvalues (and vectors) are to be calculated.
     - vectors: Set this to `true` when eigenvectors should be returned, otherwise `false`.
     - iter: QR algorithm is an iterative algorithm, `maxIter` limits the number of iterations.
 
 - Returns: A tuple containing a vector of eigenvalues, and if `vectors` is `true`, a matrix containing eigenvectors as it's columns.
 */
public func eigen<M: MatrixProtocol>(
  _ A: M,
  vectors: Bool = false,
  maxIter iter: Int = 300) -> (values: M.Vector, vectors: Matrix<M.Scalar>?)
{
  var A = Matrix(A)
  var Q_ = vectors ? Matrix<M.Scalar>.identity(A.width) : nil
  for _ in 0..<iter {
    let (Q, R) = QRDecomposition(A)
    A = R * Q
    if vectors { Q_ = Q_! * Q }
  }
  let values = M.Vector(arrayLiteral: (0..<A.width).map { A[$0, $0] })
  return (values, Q_)
}

///

/**
 Compute eigenvalues (and vectors) of the given matrix using `QR algorithm with shifts`.
 
 In linear algebra, an eigenvector of a linear transformation is a nonzero vector
 that changes at most by a scalar factor when that linear transformation is applied to it.
 The corresponding eigenvalue is the factor by which the eigenvector is scaled.
 
 In mathematical terms, we are solving the equation
 
     Ax = λx
 
 where `x` is an eigenvector and `λ` an eigenvalue.
 
 - Parameters:
     - A: A matrix representing a linear transformation whose eigenvalues (and vectors) are to be calculated.
     - vectors: Set this to `true` when eigenvectors should be returned, otherwise `false`.
     - eps: In general, this value configures the precision (and runtime) of the algorithm.
 The smaller the value, the more precise the result.
 
 - Returns: A tuple containing a vector of eigenvalues, and if `vectors` is `true`, a matrix containing eigenvectors as it's columns.
 */
public func eigen<M: MatrixScalar & ConvertibleFromPython & PythonConvertible>(
  _ A: SymmetricBandMatrix<M>,
  vectors: Bool=false,
  eps: Double = 10e-8) -> (values: Vector<M>, vectors: Matrix<M>?)
{
  let (A, U) = hess(A, calcQ: true)
  return eigen((A, U!),
               vectors: vectors,
               eps: eps)
}

func eigen<M: MatrixScalar>(
  _ hess: (A: SymTridiagonalMatrix<M>, U: Matrix<M>),
  vectors: Bool,
  eps: Double = 10e-4) -> (values: Vector<M>, vectors: Matrix<M>?)
{
  let (A, U) = hess
  var T = A
  var Q: Matrix<M>!
  
  for _ in 0..<A.width {
    var Q_: Matrix<M> = .identity(T.width)
    repeat {
      // 0. μ
      let step = T[T.lastIndex!]
      
      // 1. T = T - μI
      for i in 0..<T.width { T[i, i] -= step }
      
      // 2. QR decomposition
      let (Q, R) = QRDecomposition(T)
      
      // 3.1. T = RQ
      T = SymTridiagonalMatrix(R * Q)
      // 3.2. T = T + μΙ
      for i in 0..<T.width { T[i, i] += step }
      
      // 4.1.
      Q_ = Q_ * Q
    } while T.width > 1 && T[T.width - 2, T.width - 1] >= M(eps)

    // 4.2. Update eigenvector matrix
    Q = Q == nil ? Q_ : blockMul(Q, Q_)

    if T.width > 1 {
      // repeat algorithm for matrix without last row and column
      T = SymTridiagonalMatrix(T[0...T.width - 2, 0...T.width - 2])
    }
  }
  
  var eigenValues = Vector<M>(size: A.width)
  let X = M.gemmlt(Q, Matrix(A)) * Q
  for i in 0..<A.width { eigenValues[i] = X[i, i] }
  return (eigenValues, vectors ? U * Q : nil)
}

func blockMul<T: MatrixScalar>(_ q1: Matrix<T>, _ q2: Matrix<T>) -> Matrix<T> {
  if q1.width == q2.width { return q2 }
  
  var q2_buff: [T] = .init(repeating: 0, count: q1.width * q1.width)
  for i in 0..<q1.width {
    for j in 0..<q1.width {
      if i >= q2.width || j >= q2.width {
        if i == j { q2_buff[i * q1.width + j] = 1 }
        else { q2_buff[i * q1.width + j] = 0 }
      } else {
        q2_buff[i * q1.width + j] = q2[i, j]
      }
    }
  }
  return q1 * Matrix(arrayLiteral: q2_buff, width: q1.width, height: q1.width)
}

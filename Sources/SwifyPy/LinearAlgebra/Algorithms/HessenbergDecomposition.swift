//
//  HessenbergDecomposition.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 28/03/2020.
//

import Foundation

import PythonKit

let scipy = pyImport("scipy.linalg")
let numpy = pyImport("numpy")

/// Compute hessenberg decomposition of a dense WxH matrix.
public func hess<M: MatrixProtocol>(_ m: M) -> Matrix<M.Scalar> where M: PythonConvertible, M.Scalar: ConvertibleFromPython {
  let hess = scipy.hessenberg(numpy.reshape(m, PythonObject(tupleOf: m.width, m.width)))
  return Matrix<M.Scalar>(arrayLiteral: Array(hess)!)
}

/// Compute hessenberg decomposition of a symmetric band matrix.
public func hess<T: MatrixScalar>(_ m: SymmetricBandMatrix<T>, calcQ: Bool) -> (SymTridiagonalMatrix<T>, Matrix<T>?) where T: ConvertibleFromPython & PythonConvertible {
  let (hess, Q) = scipy.hessenberg(m, calc_q: calcQ).tuple2
  let Q_: Matrix<T>? = calcQ ? .init(arrayLiteral: Array(Q)!) : nil
  return (.init(Matrix(arrayLiteral: Array(hess)!)), Q_)
}

/// Compute hessenberg decomposition of a symmetric band matrix.
public func hess<T: MatrixScalar>(_ m: SymTridiagonalMatrix<T>) -> SymTridiagonalMatrix<T> where T: ConvertibleFromPython & PythonConvertible {
  let hess = scipy.hessenberg(m)
  return SymTridiagonalMatrix<T>(Matrix(arrayLiteral: Array(hess)!))
}

extension Matrix: PythonConvertible where Scalar: PythonConvertible {
  public var pythonObject: PythonObject {
    PythonObject(self.buffer)
  }
}

extension SymmetricBandMatrix: PythonConvertible where Scalar: PythonConvertible {
  public var pythonObject: PythonObject {
    let storage: [[Scalar]] = self.map { $0.buffer }
    return PythonObject(storage)
  }
}

extension SymTridiagonalMatrix: PythonConvertible where Scalar: PythonConvertible {
  public var pythonObject: PythonObject {
    matrix.pythonObject
  }
}

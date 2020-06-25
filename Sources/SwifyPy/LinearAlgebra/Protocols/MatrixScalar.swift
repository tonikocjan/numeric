//
//  MatrixScalar.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 01/04/2020.
//

import Accelerate
import Foundation

/// Architecture designed as per suggestion: https://forums.swift.org/t/operator-overloading-with-generics/34904/4?u=seckmaster
public protocol MatrixScalar: BinaryFloatingPoint, CVarArg, LosslessStringConvertible {
  /**
   # Matrix-matrix product.
   
   For matrix multiplication, the number of columns in the first matrix must be equal
   to the number of rows in the second matrix.
   
   The result matrix, known as the matrix product, has the number of rows
   of the first and the number of columns of the second matrix.
   
   Example:
   
       let m1: Matrix = [
         [1, 2, 3],
         [4, 5, 6]
       ]
       let m2: Matrix = [
         [7, 8],
         [9, 10],
         [11, 12]
       ]
       1> print(m1 * m2) // [[58, 64], [139, 154]]
   
   - Parameters:
       - m1: First matrix.
       - m2: Second matrix.
   
   - Returns: Matrix product of two matrices.
   */
  static func gemm(_ m1: Matrix<Self>, _ m2: Matrix<Self>) -> Matrix<Self>
  
  /// matrix-matrix product where m1 is transposed before multiplication
  static func gemmlt(_ m1: Matrix<Self>, _ m2: Matrix<Self>) -> Matrix<Self>
  
  /// matrix-matrix product where m2 is transposed before multiplication
  static func gemmrt(_ m1: Matrix<Self>, _ m2: Matrix<Self>) -> Matrix<Self>
  
  /// matrix-matrix product where m1 and m2 are transposed before multiplication
  static func gemmbt(_ m1: Matrix<Self>, _ m2: Matrix<Self>) -> Matrix<Self>
  
  /// Compute parameters for Givens rotation.
  static func rotg(a: Self, b: Self) -> (Self, Self)
  
  /// Apply Givens rotation
  static func rot(_ v1: inout Vector<Self>, _ v2: inout Vector<Self>, _ a: Self, _ b: Self)
}

extension Float: MatrixScalar {
  public static func gemm(_ m1: Matrix<Self>, _ m2: Matrix<Self>) -> Matrix<Self> {
    assert(m1.width == m2.height)
    assert(m1.height == m2.width)
    return sgemm(transA: false, transB: false, rowsA: m1.height, colsB: m2.width, colsA: m1.width, buffA: m1.buffer, buffB: m2.buffer)
  }
  
  public static func gemmlt(_ m1: Matrix<Self>, _ m2: Matrix<Self>) -> Matrix<Self> {
    assert(m2.width == m1.height)
    assert(m2.height == m1.width)
    return sgemm(transA: true, transB: false, rowsA: m1.height, colsB: m2.width, colsA: m1.width, buffA: m1.buffer, buffB: m2.buffer)
  }
  
  public static func gemmrt(_ m1: Matrix<Self>, _ m2: Matrix<Self>) -> Matrix<Self> {
    assert(m2.width == m1.height)
    assert(m2.height == m1.width)
    return sgemm(transA: false, transB: true, rowsA: m1.height, colsB: m2.width, colsA: m1.width, buffA: m1.buffer, buffB: m2.buffer)
  }
  
  public static func gemmbt(_ m1: Matrix<Self>, _ m2: Matrix<Self>) -> Matrix<Self> {
    assert(m1.width == m2.height)
    assert(m1.height == m2.width)
    return sgemm(transA: true, transB: true, rowsA: m1.height, colsB: m2.width, colsA: m1.width, buffA: m1.buffer, buffB: m2.buffer)
  }
  
  public static func rotg(a: Self, b: Self) -> (Self, Self) {
    var a = a
    var b = b
    var c: Float = 0
    var s: Float = 0
    cblas_srotg(&a, &b, &c, &s)
    return (c, s)
  }
  
  public static func rot(_ v1: inout Vector<Self>, _ v2: inout Vector<Self>, _ a: Self, _ b: Self) {
    assert(v1.count == v2.count)
    let (c, s) = rotg(a: a, b: b)
    cblas_srot(Int32(v1.count), &v1.buffer, 1, &v2.buffer, 1, c, s)
    print()
  }
}

extension Double: MatrixScalar {
  public static func gemm(_ m1: Matrix<Self>, _ m2: Matrix<Self>) -> Matrix<Self> {
    assert(m1.width == m2.height)
    assert(m1.height == m2.width)
    return dgemm(transA: false, transB: false, rowsA: m1.height, colsB: m2.width, colsA: m1.width, buffA: m1.buffer, buffB: m2.buffer)
  }
  
  public static func gemmlt(_ m1: Matrix<Self>, _ m2: Matrix<Self>) -> Matrix<Self> {
    assert(m2.width == m1.height)
    assert(m2.height == m1.width)
    return dgemm(transA: true, transB: false, rowsA: m1.height, colsB: m2.width, colsA: m1.width, buffA: m1.buffer, buffB: m2.buffer)
  }
  
  public static func gemmrt(_ m1: Matrix<Self>, _ m2: Matrix<Self>) -> Matrix<Self> {
    assert(m2.width == m1.height)
    assert(m2.height == m1.width)
    return dgemm(transA: false, transB: true, rowsA: m1.height, colsB: m2.width, colsA: m1.width, buffA: m1.buffer, buffB: m2.buffer)
  }
  
  public static func gemmbt(_ m1: Matrix<Self>, _ m2: Matrix<Self>) -> Matrix<Self> {
    assert(m1.width == m2.height)
    assert(m1.height == m2.width)
    return dgemm(transA: true, transB: true, rowsA: m1.height, colsB: m2.width, colsA: m1.width, buffA: m1.buffer, buffB: m2.buffer)
  }
  
  public static func rotg(a: Self, b: Self) -> (Self, Self) {
    var a = a
    var b = b
    var c: Double = 0
    var s: Double = 0
    cblas_drotg(&a, &b, &c, &s)
    return (c, s)
  }
  
  public static func rot(_ v1: inout Vector<Self>, _ v2: inout Vector<Self>, _ a: Self, _ b: Self) {
    assert(v1.count == v2.count)
    let (c, s) = rotg(a: a, b: b)
    cblas_drot(Int32(v1.count), &v1.buffer, 1, &v2.buffer, 1, c, s)
    print()
  }
}

/// Fast matrix product implementations using `Accelerate`.
/// NOTE: - Use `cblas` instead of `vDSP` as discussed here:
/// https://forums.swift.org/t/operator-overloading-with-generics/34904/6?u=seckmaster

func dgemm(transA: Bool, transB: Bool, rowsA: Int, colsB: Int, colsA: Int, buffA: [Double], buffB: [Double]) -> Matrix<Double> {
  var result: [Double] = .init(repeating: 0, count: rowsA * colsB)
  cblas_dgemm(CblasRowMajor,
              transA ? CblasTrans : CblasNoTrans,
              transB ? CblasTrans : CblasNoTrans,
              Int32(rowsA),
              Int32(colsB),
              Int32(colsA),
              1,
              buffA,
              Int32(colsA),
              buffB,
              Int32(rowsA),
              1,
              &result,
              Int32(rowsA))
  return Matrix(arrayLiteral: result, width: colsB, height: rowsA)
}


func sgemm(transA: Bool, transB: Bool, rowsA: Int, colsB: Int, colsA: Int, buffA: [Float], buffB: [Float]) -> Matrix<Float> {
  var result: [Float] = .init(repeating: 0, count: rowsA * colsB)
  cblas_sgemm(CblasRowMajor,
              transA ? CblasTrans : CblasNoTrans,
              transB ? CblasTrans : CblasNoTrans,
              Int32(rowsA),
              Int32(colsB),
              Int32(colsA),
              1,
              buffA,
              Int32(colsA),
              buffB,
              Int32(rowsA),
              1,
              &result,
              Int32(rowsA))
  return Matrix(arrayLiteral: result, width: colsB, height: rowsA)
}

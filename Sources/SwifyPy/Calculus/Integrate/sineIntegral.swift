//
//  sineIntegral.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 06/04/2020.
//

import Foundation

public func sinc(_ x: Double) -> Double {
  if x == 0 { return 1 }
  return sin(x) / x
}

// NOTE: - Not viable for large inputs (> 25)!
public func taylorExpansionSineIntegral<Scalar: MatrixScalar>(_ x: Scalar, n: Int) -> Scalar {
  taylorExpansionIterator(x).prefix(n).reduce(0.0, +)
}

/**
 Generate Taylor series coefficients for computing sine integral.
 */
public func taylorExpansionIterator<Scalar: MatrixScalar>(_ x: Scalar) -> AnyIterator<Scalar> {
  var sign = true
  var x_ = x
  var f: Scalar = 1
  var iter: Scalar = 1
  return .init {
    defer {
      sign.toggle()
      iter += 2
      x_ *= x * x
      f *= iter * (iter - 1)
    }
    return (sign ? x_ : -x_) / (f * iter)
  }
}

/**
 Calculate sine integral using provided method.
 */
public func sineIntegral(
  x: Double,
  method: (Function<Double, Double>, (Double, Double), Int) -> Double,
  k: Int = 10) -> Double
{
  method(Function(sinc), (0, x), k)
}

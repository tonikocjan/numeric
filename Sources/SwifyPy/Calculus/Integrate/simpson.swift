//
//  simpson.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 06/04/2020.
//

import Foundation

/**
 Compute the area under the given curve inside the interval.
 
 - Parameters:
     - f: Function to be integrated.
     - interval: Region of the area.
     - n: Number of steps.
 */
public func simpson<Scalar: MatrixScalar>(
  _ f: Function<Scalar, Scalar>,
  interval: (a: Scalar, b: Scalar),
  n: Int) -> Scalar
{
  let (a, b) = interval
  let n = Scalar(n)
  let h = (b - a) / (2 * n)
  var S = f(a) + f(b) + 4 * f(a + h)
  for i in stride(from: Scalar(1), through: n-1, by: 1) {
    let x = a + 2 * i * h
    S += 2 * f(x) + 4 * f(x + h)
  }
  return S * (h / 3.0)
}

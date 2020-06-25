//
//  trapezoidial.swift
//  PythonKit
//
//  Created by Toni Kocjan on 06/04/2020.
//

import Foundation

/**
 Compute the area under curve of the given function inside the interval.
 
 - Parameters:
     - f: Function to be integrated.
     - interval: Region of the area.
     - n: Number of steps.
 */
public func trapezoidial<Scalar: MatrixScalar>(
  _ f: Function<Scalar, Scalar>,
  interval: (a: Scalar, b: Scalar),
  n: Int) -> Scalar
{
  let (a, b) = interval
  let n = Scalar(n)
  var t = (f(a) + f(b)) / 2.0
  let h = (b - a) / n
  for i in stride(from: Scalar(1), through: n-1, by: 1) {
    let p = a + i * h
    t += f(p)
  }
  return t * h
}

// TODO: - Not working correctly!
public func trapezoidial<Scalar: MatrixScalar>(
  _ f: Function<Scalar, Scalar>,
  interval: (a: Scalar, b: Scalar),
  n: Int,
  eps: Scalar) -> Scalar
{
  let (a, b) = interval
  var e = eps * 2
  var m = 0
  var h = b - a
  var T = h * (f(a) + f(b)) / 2
  var k = Scalar(1)
  while m < n && abs(e) > eps {
    h = h / 2
    let s = stride(from: 0, to: k, by: 1).reduce(Scalar.zero) {
      $0 + f(a + 2 * $1 * h)
    }
    e = s * h - T / 2
    T += e
    
    m += 1
    k *= 2
  }
  if abs(e) > eps {
    T = .nan
  }
  return T
}

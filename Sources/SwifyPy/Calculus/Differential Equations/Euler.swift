//
//  Euler.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 17/05/2020.
//

import Foundation

public func euler(
  x0: Double,
  y0: Double,
  N: Int,
  h: Double,
  f: Function<(Double, Double), Double>
) -> (Double, Double) {
  var x = x0
  var y = y0
  for _ in 0..<N {
    y += h * f((x, y))
    x += h
  }
  return (x, y)
}

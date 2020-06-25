//
//  RungeKutta.swift
//  PythonKit
//
//  Created by Toni Kocjan on 16/05/2020.
//

import Foundation

public func rungeKutta(
  x0: Double,
  y0: Double,
  N: Int,
  h: Double,
  f: Function<(Double, Double), Double>
) -> (Double, Double) {
  var x = x0
  var y = y0
  for _ in 0..<N {
    let k1 = h * f((x, y))
    let k2 = h * f((x + h * 0.5, y + k1 * 0.5))
    let k3 = h * f((x + h * 0.5, y + k2 * 0.5))
    let k4 = h * f((x + h , y + k3))
    y += (k1 + 2 * k2 + 2 * k3 + k4) / 6
    x += h
  }
  return (x, y)
}

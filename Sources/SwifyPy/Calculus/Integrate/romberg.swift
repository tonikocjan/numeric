//
//  romberg.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 07/04/2020.
//

import Foundation

/**
 Compute the area under the given curve inside the interval.
 
 - Parameters:
     - f: Function to be integrated.
     - interval: Region of the area.
     - n: Number of steps.
 */
public func romberg(
  _ f: Function<Double, Double>,
  interval: (a: Double, b: Double),
  n: Int) -> Double
{
  let (a, b) = interval
  var h = b - a
  
  if n == 1 { return h * (f(a) + f(b)) / 2 }
  
  var T = Matrix<Double>(width: n + 1, height: 2)
  T[0, 0] = h * (f(a) + f(b)) / 2
  
  var pow2 = 1
  
  for m in 1...n {
    let y_ = m % 2 == 0 ? 1 : 0
    let y = m % 2 == 0 ? 0 : 1
   
    h = h / 2
    T[y, 0] = T[y_, 0] / 2
    
    var s = 0.0
    for i in 1...pow2 {
      s += f(a + (2 * Double(i) - 1) * h)
    }
    T[y, 0] += h * s
    
    var pow4 = 4.0
    for n in 1...m {
      T[y, n] = (pow4 * T[y, n - 1] - T[y_, n - 1]) / (pow4 - 1)
      pow4 *= 4
    }
    
    pow2 *= 2
  }
  return T[n % 2 == 0 ? 0 : 1, n]
}

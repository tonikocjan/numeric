//
//  Laplace2D.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 17/03/2020.
//

import Foundation

func repeating<T>(_ value: T, _ count: Int) -> [T] {
  .init(repeating: value, count: count)
}

func ones<T: MatrixScalar>(_ count: Int) -> [T] {
  .init(repeating: 1, count: count)
}

func vcat<T>(_ a: [T], _ b: [T]) -> [T] {
  a + b
}

func vcat<T>(_ a: [T], _ b: T) -> [T] {
  a + [b]
}

func vcat<T>(_ a: T, _ b: [T]) -> [T] {
  [a] + b
}

func LinRange(from: Double, to: Double, steps: Int) -> [Double] {
  let step = (to - from) / Double(steps - 1)
  var range: [Double] = []
  for i in 0..<steps {
    range.append(from + step * Double(i))
  }
  return range
}

/**
 Solving the minimal surface problem using Laplace differential equations.
 */
public enum Laplace2D {
  /**
   Compute the approximate solution to the boundary problem for the Laplace equation
   in 2D inside the rectangle bounded by `(a, b) x (c, d)`, where the values on the edges
   are computed with
   
   u(x, c) = fs(x)
   u(b, y) = fd(y)
   u(x, d) = fz(x)
   u(a, y) = fl(y)
   
   - Parameters:
   - fs: Function providing values for bottom edge.
   - fd: Function providing values for right edge.
   - fz: Function providing values for top edge.
   - fl: Function providing values for left edge.
   - h: The discretization step.
   - bounds: The rectangular bounds `(a, b) x (c, d)`.
   
   - Returns:
   - Z: Matrix containing the solution.
   - x: Vector representing the x-axis.
   - x: Vector representing the y-axis.
   */
  public static func solveBoundaryProblem(
    fs: (Double) -> Double,
    fd: (Double) -> Double,
    fz: (Double) -> Double,
    fl: (Double) -> Double,
    h: Double,
    bounds: ((a: Double, b: Double), (c: Double, d: Double))
  ) -> (Z: Matrix<Double>, x: Vector<Double>, y: Vector<Double>)
  {
    let ((a, b), (c, d)) = bounds
    let m = Int(floor(b - a) / h)
    let n = Int(floor(d - c) / h)
    let x = LinRange(from: a, to: b, steps: n + 1)
    let y = LinRange(from: c, to: d, steps: m + 1)
    
    let L: BandMatrix<Double> = coefficientsMatrix(n: n - 1, m: m - 1)
    let v = rightHandSides(s: x.dropFirst().dropLast().map(fs),
                           d: y.dropFirst().dropLast().map(fd),
                           z: x.dropFirst().dropLast().map(fz),
                           l: y.dropFirst().dropLast().map(fl))
    let u = v !/ L
    var Z = Matrix<Double>.zeros(width: m + 1, height: n + 1)
    
    for i in 1..<Z.height - 1 {
      for j in 1..<Z.width - 1 {
        Z[i, j] = u[(i - 1) * (Z.width - 2) + (j - 1)]
      }
    }
    
    for i in 0..<Z.height {
      Z[i, 0] = fl(y[i])
    }
    
    for i in 0..<Z.height {
      Z[i, Z.width - 1] = fd(y[i])
    }
    
    for i in 0..<Z.width {
      Z[0, i] = fs(x[i])
    }
    
    for i in 0..<Z.width {
      Z[Z.height - 1, i] = fz(x[i])
    }
    
    return (Z: Z,
            x: Vector<Double>(arrayLiteral: x),
            y: Vector<Double>(arrayLiteral: y))
  }
}

/// Implementation details, hidden to the users of the library.
extension Laplace2D {
  /**
   Compute the coefficients matrix for Laplace operator in 2D inside a rectangular bounds.
   
   - Parameters:
   - n: Width of the matrix
   - m: Height of the matrix.
   
   - Returns: A banded matrix that represents the coefficients of the system of equations
   for the discretized Laplace equation.
   */
  static func coefficientsMatrix<T>(n: Int, m: Int) -> BandMatrix<T> {
    assert(m == n) // TODO: - band matrices are square matrices
    let size = m * n
    
    let d1: Vector<T> = .init(arrayLiteral: vcat(repeating(vcat(ones(n - 1), T.zero), m - 1).flatMap { $0 },
                                                 ones(n - 1)))
    
    return .init(size: size, diagonals: [0: .repeating(size, value: -4),
                                         n: .ones(size - n),
                                         -n: .ones(size - n),
                                         1: d1,
                                         -1: d1])
  }
  
  /**
   Compute right-hand-sides for solving the boundary problem for Laplace equation in 2D.
   
   - Parameters:
   - s: A vector whose values represent bottom edge.
   - d: A vector whose values represent right edge.
   - z: A vector whose values represent top edge.
   - l: A vector whose values represent left edge.
   
   - Returns: A vector containing constant terms of the linear system of equations.
   */
  static func rightHandSides<T: MatrixScalar>(
    s: Vector<T>,
    d: Vector<T>,
    z: Vector<T>,
    l: Vector<T>) -> Vector<T>
  {
    assert(s.count == z.count)
    assert(l.count == d.count)
    let n = s.count
    let m = d.count
    let size = n * m
    var b = Vector<T>.zeros(size)
    
    for i in 0..<n {
      b[i] = s[i]
    }
    
    for (i, j) in ((size - n)..<size).enumerated() {
      b[j] = z[i]
    }
    
    for (i, j) in stride(from: 0, to: size, by: n).enumerated() {
      b[j] += l[i]
    }
    
    for (i, j) in stride(from: n - 1, to: size, by: n).enumerated() {
      b[j] += d[i]
    }
    
    return -b
  }
}

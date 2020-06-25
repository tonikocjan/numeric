//
//  gravity.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 08/04/2020.
//

import Foundation

/**
 Compute the gravity between two unit cubes, distanced `[1, 0, 0]`.
 We may assume that all physical constants in the computation are `1`.
 
 A couple methods are provided:
    1. A naive method which sums the forces between points uniformly sampled from both cubes.
       It's time complexity is `O(samples⁶)`, where `samples = 1 / d`.
    2. By exploting symmetry we can optimize the naive approach to `O(n⁴)`.
    3. MC algorithm (Monte-Carlo), which randomly samples points from both cubes and sums the forces.
       It's time complexity is `O(n¹)`.
    4. Applying the same observation as in [2], we improve the MC algorithm.
    5. Approximation using chebysev polynomials. It's time complexity is `O(n⁶)`, where `n` is the degree
       of the polynomial.
 */

///

/**
 Compute the force between two unitary homogenous cubes distanced 1.
 
 The attraction is calculated by uniformly sampling points from both cubes
 and suming the force between every pair. The force between the cube is mean
 of the obtained value.
 
 - Complexity: `O((1/d)⁶)`
 
 - Parameters:
     - G: Gravitational constant.
     - d: Delta in all three dimensions, dx, dy, dz. Number of sampled points equals `2 * (1 / d)³`.
 */
public func gravityNaive(G: Double = 1, d: Double = 0.05) -> Vector<Double> {
  assert((0...1).contains(d))
  
  var samples = 0
  var I = Vector<Double>(size: 3)
  var p1 = Vector<Double>(size: 3)
  var p2 = Vector<Double>(size: 3)
  
  for x1 in stride(from: 0.0, through: 1.0, by: d) {
    p1[0] = x1
    for y1 in stride(from: 0.0, through: 1.0, by: d) {
      p1[1] = y1
      for z1 in stride(from: 0.0, through: 1.0, by: d) {
        p1[2] = z1
        for x2 in stride(from: 2.0, through: 3.0, by: d) {
          p2[0] = x2
          for y2 in stride(from: 0.0, through: 1.0, by: d) {
            p2[1] = y2
            for z2 in stride(from: 0.0, through: 1.0, by: d) {
              p2[2] = z2
              I = I + gravityPoint(p1, p2, G: G)
              samples += 1
            }
          }
        }
      }
    }
  }
  return I / Double(samples)
}

/**
 Compute the force between two unitary homogenous cubes distanced 1.
 
 This method is an optimized version of `gravityNaive(:)` by exploiting symmetry.
 We still sample `n³` points from one cube, but only `n` points (points parallel to
 x-axis).
 
 Because this algorithm is `θ(n²)` faster than original, we can compute the integral with `θ(n√n)`
 points in the same running time, therefore expecting to converge faster.
 
 - Complexity: `O((1/d)⁴)`
 
 - Parameters:
     - G: Gravitational constant.
     - d: Delta in all three dimensions, dx, dy, dz. Number of sampled points equals `2 * (1 / d)³`.
 */
public func gravityNaive2(G: Double = 1, d: Double = 0.05) -> Vector<Double> {
  assert((0...1).contains(d))
  
  var samples = 0
  var I = Vector<Double>(size: 3)
  var p1 = Vector<Double>(size: 3)
  var p2 = Vector<Double>(size: 3)
  
  for x1 in stride(from: 0.0, through: 1.0, by: d) {
    p1[0] = x1
    for y1 in stride(from: 0.0, through: 1.0, by: d) {
      p1[1] = y1
      p2[1] = y1
      for z1 in stride(from: 0.0, through: 1.0, by: d) {
        p1[2] = z1
        p2[2] = z1
        for x2 in stride(from: 2.0, through: 3.0, by: d) {
          p2[0] = x2
          I = I + gravityPoint(p1, p2, G: G)
          samples += 1
        }
      }
    }
  }
  return I / Double(samples)
}

/**
 Compute the force between two unitary homogenous cubes distanced 1.
 
 This method computes the force using `Plain Monte Carlo` algorithm. It works by randomly
 sampling `2 * n` points from the cubes, suming gravity between every pair and computing
 their mean.
 
 - Complexity: `O(n)`
 
 - Parameters:
     - G: Gravitational constant.
     - sampleSize: Number of points to be samples.
 */
public func gravityMC2(G: Double = 1, sampleSize n: Int = 1_000_000) -> Vector<Double> {
  var I = Vector<Double>(size: 3)
  var p1 = Vector<Double>(size: 3)
  var p2 = Vector<Double>(size: 3)
  for _ in 0..<n {
    p1[0] = .random(in: 0...1)
    p1[1] = .random(in: 0...1)
    p1[2] = .random(in: 0...1)
    p2[0] = .random(in: 2...3)
    p2[1] = p1[1]
    p2[2] = p1[2]
    I = I + gravityPoint(p1, p2, G: G)
  }
  return I / Double(n)
}

/**
 Compute the force between two unitary homogenous cubes distanced 1.
 
 The force is approximated using Chebyshev nodes of the chosen kind.
 
 - Complexity: O(n⁶)
 
 - Parameters:
     - G: Gravitational constant.
     - points: Number of roots of the Chebyshev polynomial which are used for approximation.
     - kind: Use `first` or `second` kind Chebyshev nodes.
 */
public func gravityChebysev(
  G: Double = 1,
  points n: Int = 10,
  kind: ChebyshevKind = .first) -> Vector<Double>
{
  // https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/23972/versions/22/previews/chebfun/examples/quad/html/TwoCubes.html
  
  /**
   Compute a chebysev node on interval (-1, 1).
   
   https://en.wikipedia.org/wiki/Chebyshev%E2%80%93Gauss_quadrature
   https://people.maths.ox.ac.uk/trefethen/cheb2paper.pdf
   https://en.wikipedia.org/wiki/Chebyshev_nodes
   
   - Parameter k: Index of the node.
   */
  func chebysevNode1st(k: Double) -> Double {
    cos(.pi * Double(2 * k - 1) / (Double(2 * n)))
  }
  
  func chebysevNode2nd(k: Double) -> Double {
    cos(.pi * Double(k) / Double(n + 1))
  }
  
  /**
   Convert a chebysev node to an abritrary interval [A, B].
   */
  func convertNode(_ node: Double, to interval: (A: Double, B: Double)) -> Double {
    let (a, b) = interval
    return 0.5 * (a + b) + (0.5 * (b - a) * node)
  }
  
  func chebysevWeights1st() -> Vector<Double> {
    .repeating(n, value: 1.0 / Double(n))
  }
  
  func chebysevWeights2nd() -> Vector<Double> {
    var weights = Vector<Double>(size: n)
    for i in 1...n {
      weights[i - 1] = (.pi / Double(n + 1)) * pow(sin(.pi * Double(i) / (Double(n + 1))), 2)
    }
    return weights
  }
  
  let nodes: Vector<Double>
  let weights: Vector<Double>
    
  switch kind {
  case .first:
    nodes = stride(from: 1, through: Double(n), by: 1)
      .map(chebysevNode1st)
      .map { convertNode($0, to: (0, 1)) }
    weights = chebysevWeights1st()
  case .second:
    nodes = stride(from: 1, through: Double(n), by: 1)
      .map(chebysevNode2nd)
      .map { convertNode($0, to: (0, 1)) }
    weights = chebysevWeights2nd()
  }
  
  assert(nodes.count == weights.count)
  
  var I = Vector<Double>(size: 3)
  for x1 in 0..<n {
    for y1 in 0..<n {
      for z1 in 0..<n {
        for x2 in 0..<n {
          for y2 in 0..<n {
            for z2 in 0..<n {
              let p1 = Vector(arrayLiteral: nodes[x1], nodes[y1], nodes[z1])
              let p2 = Vector(arrayLiteral: nodes[x2] + 2, nodes[y2], nodes[z2])
              let weight = weights[x1] * weights[y1] * weights[z1] * weights[x2] * weights[y2] * weights[z2]
              I = I + gravityPoint(p1, p2, G: G) * weight
            }
          }
        }
      }
    }
  }
  return I
}

/**
 Compute the force between two unitary homogenous cubes distanced 1.
 
 The force is approximated using Gauss-Legendre nodes.
 
 - Complexity: O(n⁶)
 
 - Parameters:
     - G: Gravitational constant.
     - points: Number of roots of the Chebyshev polynomial which are used for approximation.
 */
public func gravityGaussLegendre(G: Double = 1, points n: Int = 10) -> Vector<Double> {
  func generateGaussLegendrePoints() -> (x: Vector<Double>, w: Vector<Double>) {
    // https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/23972/versions/22/previews/chebfun/examples/quad/html/GaussQuad.html
    func jacobiMatrix() -> SymmetricBandMatrix<Double> {
      SymmetricBandMatrix(arrayLiteral: [
        .repeating(n, value: 1), // translate matrix by I, otherwise our `eigen` implementation doesn't converge
        (1..<n).map { Double($0) }.map { (a: Double) -> Double in 0.5 / sqrt(1.0 - pow((2.0 * a), -2.0)) }
      ])
    }
    
    let (V, D) = eigen(jacobiMatrix(), vectors: true, maxIter: 1000)
    
    let x = V - 1 // need to translate by -1
    let w = (0..<n).map { 2 * pow(D![0, $0], 2) }
    return (x, w)
  }
  
  /**
   Convert a node to an abritrary interval [A, B].
   */
  func convertNode(_ node: Double, to interval: (A: Double, B: Double)) -> Double {
    let (a, b) = interval
    return 0.5 * (a + b) + (0.5 * (b - a) * node)
  }
  
  let (x_, w) = generateGaussLegendrePoints()
  let x = x_.map { convertNode($0, to: (1, 0)) }
  
  let n = x.count
  var I = Vector<Double>(size: 3)
  for x1 in 0..<n {
    for y1 in 0..<n {
      for z1 in 0..<n {
        for x2 in 0..<n {
          for y2 in 0..<n {
            for z2 in 0..<n {
              let p1 = Vector(arrayLiteral: x[x1], x[y1], x[z1])
              let p2 = Vector(arrayLiteral: x[x2] + 2, x[y2], x[z2])
              let weight = w[x1] * w[y1] * w[z1] * w[x2] * w[y2] * w[z2]
              I = I + gravityPoint(p1, p2, G: G) * weight
            }
          }
        }
      }
    }
  }
  return I / 64
}

@inline(__always)
func gravityPoint(_ p1: Vector<Double>, _ p2: Vector<Double>, G: Double) -> Vector<Double> {
  let diff = p1 - p2
  return G * diff / pow(diff.magnitude, 3)
}

public enum ChebyshevKind {
  case first, second
}

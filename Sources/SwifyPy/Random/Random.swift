//
//  Random.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 27/03/2020.
//

import Foundation

#if os(macOS)
import GameplayKit

public typealias RandomGenerator = () -> Float

@available(OSX 10.11, *)
public func randnGenerator(mean: Float, deviation: Float, seed: UInt64) -> RandomGenerator {
  let distribution = GaussianDistribution(randomSource: GKMersenneTwisterRandomSource(seed: seed),
                                          mean: mean,
                                          deviation: deviation)
  return { distribution.nextFloat() }
}

@available(OSX 10.11, *)
public func randnGenerator(mean: Float, deviation: Float) -> RandomGenerator {
  let distribution = GaussianDistribution(randomSource: GKMersenneTwisterRandomSource(),
                                          mean: mean,
                                          deviation: deviation)
  return { distribution.nextFloat() }
}

public func randn(shape: (width: Int, height: Int), generator: RandomGenerator) -> Matrix<Float> {
  var matrix = Matrix<Float>(width: shape.width, height: shape.height)
  for i in 0..<shape.height {
    for j in 0..<shape.width {
      matrix[i, j] = generator()
    }
  }
  return matrix
}

public func randn(count: Int, generator: RandomGenerator) -> Vector<Float> {
  var vector = Vector<Float>(size: count)
  for i in 0..<count {
    vector[i] = generator()
  }
  return vector
}

@available(OSX 10.11, *)
class GaussianDistribution {
  let randomSource: GKRandomSource
  let mean: Float
  let deviation: Float
  
  init(randomSource: GKRandomSource, mean: Float, deviation: Float) {
    precondition(deviation >= 0)
    self.randomSource = randomSource
    self.mean = mean
    self.deviation = deviation
  }
  
  /// Box-Muller transformation.
  func nextFloat() -> Float {
    guard deviation > 0 else { return mean }
    
    let x1 = randomSource.nextUniform() // a random number between 0 and 1
    let x2 = randomSource.nextUniform() // a random number between 0 and 1
    let z1 = sqrt(-2 * log(x1)) * cos(2 * Float.pi * x2) // z1 is normally distributed
    
    // Convert z1 from the Standard Normal Distribution to our Normal Distribution
    return z1 * deviation + mean
  }
}

#endif

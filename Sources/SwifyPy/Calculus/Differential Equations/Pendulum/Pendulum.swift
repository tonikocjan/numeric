//
//  Pendulum.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 09/05/2020.
//

import Foundation

public enum Pendulum {
  /**
   Compute the acceleration of a `mathematical pendulum`.
   
   - Parameters:
       - g: Force of gravity.
       - L: Length of the pendulum.
       - theta: Angle.
       - dtheta: Velocity
       - μ: Loss of energy factor (air resistence, friction, ...).
   */
  public static func acceleration(
    G g: Double = 9.80665,
    L: Double,
    theta angle: Double,
    dtheta velocity: Double,
    μ mu: Double
  ) -> Double {
    -g / L * sin(angle) - mu * velocity
  }
  
  /**
   Simulate - predict the angle and velocity of the pendulum based on initial condition.
   
   This method computes the initial condition problem of the differential equation using
   runge-kutta method.
   
   - Parameters:
       - g: Force of gravity.
       - L: Length of the pendulum.
       - theta: Angle.
       - dtheta: Velocity
       - μ: Loss of energy factor (air resistence, friction, ...).
       - time: How much time has passed.
       - n: Split the interval on several smaller intervals.
   */
  public static func simulate(
    G g: Double = 9.80665,
    L: Double,
    theta angle: Double,
    dtheta velocity: Double,
    μ mu: Double,
    time: Double,
    n: Int
  ) -> (angle: Double, velocity: Double) {
    let f: Function<(Double, Double), Double> = .init { (theta, dtheta) in
      acceleration(G: g, L: L, theta: theta, dtheta: dtheta, μ: mu)
    }
    
    let h = time / Double(n)
    var x = angle
    var y = velocity
    
    for _ in 0..<n {
      x += h * y

      // euler:
//      let euler = y + h * f((x, y))

      // runge-kutta:
      let k1 = h * f((x, y))
      let k2 = h * f((x + h * 0.5, y + k1 * 0.5))
      let k3 = h * f((x + h * 0.5, y + k2 * 0.5))
      let k4 = h * f((x + h , y + k3))
      let runge = y + (k1 + 2 * k2 + 2 * k3 + k4) / 6

      y = runge
    }

    return (x, y)
  }
}

public extension Pendulum {
  /**
   Compute the acceleration of a `harmonic pendulum`.
   
   - Parameters:
       - g: Force of gravity.
       - L: Length of the pendulum.
       - theta: Angle.
       - time: How much time has passed.
   */
  static func harmonic(
    G g: Double = 9.80665,
    L: Double,
    theta angle: Double,
    time: Double
  ) -> Double {
    angle * cos(sqrt(g / L) * time)
  }
}

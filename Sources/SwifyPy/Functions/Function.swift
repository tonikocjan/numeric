//
//  Function.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 06/04/2020.
//

import Foundation

public struct Function<Input, Output> {
  public let f: (Input) -> Output
  
  public init(_ f: @escaping (Input) -> Output) {
    self.f = f
  }
  
  @inline(__always)
  public func callAsFunction(_ input: Input) -> Output {
    f(input)
  }
}

public extension Function where Input == Output, Input == Double {
  typealias U = Input
  
  enum Method {
    case trapezoidial
    case simspon
    case romberg
  }
  
  @inline(__always)
  func integrate(on interval: (U, U), n: Int) -> U {
    integrate(on: interval, n: n, method: .romberg)
  }
  
  @inline(__always)
  func integrate(on interval: (U, U), n: Int, method: Method) -> U {
    switch method {
    case .trapezoidial:
      return trapezoidial(self, interval: interval, n: n)
    case .simspon:
      return simpson(self, interval: interval, n: n)
    case .romberg:
      return romberg(self, interval: interval, n: n)
    }
  }
}

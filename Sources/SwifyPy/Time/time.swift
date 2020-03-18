//
//  time.swift
//  PythonKit
//
//  Created by Toni Kocjan on 18/03/2020.
//

import Foundation

public func timePerformance(_ execute: () -> Void) -> Double {
  let startTime = CFAbsoluteTimeGetCurrent()
  execute()
  return CFAbsoluteTimeGetCurrent() - startTime
}

public func timePerformance<T>(_ execute: () -> T) -> (time: Double, result: T) {
  let startTime = CFAbsoluteTimeGetCurrent()
  let result = execute()
  let time = CFAbsoluteTimeGetCurrent() - startTime
  return (time, result)
}

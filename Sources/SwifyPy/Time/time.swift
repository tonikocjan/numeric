//
//  time.swift
//  PythonKit
//
//  Created by Toni Kocjan on 18/03/2020.
//

import Foundation

#if os(macOS)
let currentTime: () -> Double = CFAbsoluteTimeGetCurrent
#else
let currentTime: () -> Double = { Date().timeIntervalSince1970 }
#endif

public func timePerformance(_ execute: () -> Void) -> Double {
  let startTime = currentTime()
  execute()
  return currentTime() - startTime
}

public func timePerformance<T>(_ execute: () -> T) -> (time: Double, result: T) {
  let startTime = currentTime()
  let result = execute()
  let time = currentTime() - startTime
  return (time, result)
}

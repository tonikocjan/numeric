//
//  time.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 18/03/2020.
//

import Foundation

#if os(macOS)
let currentTime: () -> Double = CFAbsoluteTimeGetCurrent
#else
let currentTime: () -> Double = { Date().timeIntervalSince1970 }
#endif

public func benchmark(_ execute: () -> Void) -> Double {
  let startTime = currentTime()
  execute()
  return currentTime() - startTime
}

public func benchmark<T>(
  trials: Int = 100,
  _ execute: () -> T) -> (time: Double, result: T)
{
  var times = [Double]()
  var result: T!
  for i in 0..<trials {
    let startTime = currentTime()
    result = execute()
    let time = currentTime() - startTime
    times.append(time)
  }
  return (times.reduce(0, +) / Double(times.count), result)
}

public func benchmark<T>(
  trials: Int,
  setup: () -> T,
  run: (T) -> Void,
  verbose: Bool = false) -> Double
{
  func progressBar(_ i: Int) -> String {
    let progress: String = ((0..<i).map { _ in "-" }).joined(separator: "")
    let missing: String = (((i..<trials).map { _ in " " }).joined(separator: ""))
    return "\(i) of \(trials) [\(progress)\(missing)]"
  }
  
  func displayProgressBar(_ bar: String) {
    print("\u{1B}[1A\u{1B}[K\(bar)")
  }
  
  let prep = setup()
  let times: [Double] = (0..<trials).map { (i: Int) -> Double in
    if verbose {
      displayProgressBar(progressBar(i))
    }
    return benchmark { run(prep) }
  }
  if verbose { displayProgressBar(progressBar(trials)) }
  return times.reduce(0, +) / Double(trials)
}

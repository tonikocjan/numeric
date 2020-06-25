//
//  matplotlib.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 17/03/2020.
//

import Foundation
import PythonKit

func pyImport(_ name: String) -> PythonObject {
  try! Python.attemptImport(name)
}

public let sys = pyImport("sys")
let matplotlib = pyImport("matplotlib")
let np = pyImport("numpy")

public let plt: PythonObject = {
  #if os(macOS)
  // NOTE: - having issues with other backends on macOS,
  // tested on Ubuntu and it works with default backend!
  matplotlib.use("WebAgg")
  #endif
  return try! Python.attemptImport("matplotlib.pyplot")
}()

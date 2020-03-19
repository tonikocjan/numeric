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

/// Draw 3D surface.
public func surface<M: MatrixProtocol>(x: M.Vector, y: M.Vector, Z: M) where M.Value: PythonConvertible {
  let mplot3d = pyImport("mpl_toolkits.mplot3d")
  _ = mplot3d.Axes3D
  
  #if os(macOS)
  // NOTE: - having issues with other backends on macOS,
  // tested on Ubuntu and it works with default backend!
  matplotlib.use("WebAgg")
  #endif
  
  let plt = try! Python.attemptImport("matplotlib.pyplot")
  let cm = pyImport("matplotlib.cm")
  let np = pyImport("numpy")
  
  let fig = plt.figure()
  let ax = fig.gca(projection: "3d")
  
  var X = np.array(Array(x))
  var Y = np.array(Array(y))
  (X, Y) = np.meshgrid(X, Y).tuple2
  let Z1 = np.array(Array(Z.map { Array($0) }))
  
  ax.plot_surface(X, Y, Z1,
                  linewidth: 0,
                  antialiased: false,
                  cmap: cm.coolwarm)
  
  plt.show()
}

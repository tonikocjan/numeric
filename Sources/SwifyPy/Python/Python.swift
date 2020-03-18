//
//  matplotlib.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 17/03/2020.
//

import Foundation
import PythonKit

public typealias PythonObject = PythonKit.PythonObject

public func pyImport(_ name: String) -> PythonObject {
  try! Python.attemptImport(name)
}

public let sys = pyImport("sys")
public let matplotlib = pyImport("matplotlib")

/// Draw 3D surface.
public func surface<M: MatrixProtocol>(x: M.Vector, y: M.Vector, Z: M) where M.Value: PythonConvertible {
  let mplot3d = pyImport("mpl_toolkits.mplot3d")
  _ = mplot3d.Axes3D
  
  matplotlib.use("WebAgg")
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

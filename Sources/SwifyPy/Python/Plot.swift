//
//  Plot.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 28/03/2020.
//

import PythonKit
import Foundation

/// Draw 3D surface.
public func surface<M: MatrixProtocol>(x: M.Vector, y: M.Vector, Z: M) where M.Scalar: PythonConvertible {
  let mplot3d = pyImport("mpl_toolkits.mplot3d")
  _ = mplot3d.Axes3D
  
  let cm = pyImport("matplotlib.cm")
  
  let fig = plt.figure()
  let ax = fig.gca(projection: "3d")
  
  var X = np.array(x.buffer)
  var Y = np.array(y.buffer)
  (X, Y) = np.meshgrid(X, Y).tuple2
  let Z1 = np.array(Array(Z.map { Array($0) }))
  
  ax.plot_surface(X, Y, Z1,
                  linewidth: 0,
                  antialiased: false,
                  cmap: cm.coolwarm)
  
  plt.show()
}

public func scatter<T: MatrixScalar>(x: Vector<T>, y: Vector<T>, color: String? = nil, show: Bool = true) where T: PythonConvertible {
  scatter(x: x.buffer, y: y.buffer, color: color, show: show)
}

public func scatter<T: MatrixScalar>(points: [Point<T>], color: String? = nil, show: Bool = true) where T: PythonConvertible {
  scatter(x: points.map { $0.x }, y: points.map { $0.y }, color: color, show: show)
}

public func scatter<T: MatrixScalar>(x: [T], y: [T], color: String? = nil, show: Bool = true) where T: PythonConvertible {
  plt.scatter(x, y, c: color)
  if show { plt.show() }
}

public func scatter<T: MatrixScalar>(y: Vector<T>) where T: PythonConvertible {
  scatter(y: y.buffer)
}

public func scatter<T: MatrixScalar>(y: [T]) where T: PythonConvertible {
  plt.scatter(Array(0..<y.count), y)
  plt.show()
} 

public func spy<M: MatrixProtocol>(_ Z: M) where M.Scalar: PythonConvertible {
  let Z = np.array(Array(Z.map { Array($0) }))
  plt.spy(Z)
  plt.show()
}

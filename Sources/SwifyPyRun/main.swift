import SwifyPy
import Foundation

/// Higher-order function transforming input argument into a function
/// which negates all it's outputs.
func neg(_ f: @escaping (Double) -> Double) -> (Double) -> Double {
  { -f($0) }
}

let (time, (Z, x, y)) = timePerformance {
  Laplace2D.solveBoundaryProblem(fs: sin,
                                 fd: neg(sin),
                                 fz: sin,
                                 fl: neg(sin),
                                 h: 0.075,
                                 bounds: ((0, .pi), (0, .pi)))
}

print("!!! Took \(time) seconds !!!")

print(x)
print()
print(y)
print()
print(Z)

print("Python \(sys.version_info.major).\(sys.version_info.minor)")
print("Python Version: \(sys.version)")

surface(x: x, y: y, Z: Z)

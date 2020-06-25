//
//  SpectralGrouping.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 28/03/2020.
//

import Foundation

/// - Complexity: O(n²) where `n = points.count`
public func similarityGraph<T: MatrixScalar>(
  from points: [Point<T>],
  eps: T) -> Graph<IndexedPoint<T>>
{
  // TODO: - optimize using `KDTree`!
  var graph = Graph<IndexedPoint<T>>()
  for i in points.indices {
    let a = IndexedPoint(index: i, point: points[i])
    graph.addNode(a)
    for j in points.indices {
      if i == j { continue }
      let b = IndexedPoint(index: j, point: points[j])
      if a.distance(to: b) < eps {
        graph.addEdge(from: a,
                      to: b,
                      isDirected: false)
      }
    }
  }
  return graph
}

public extension Graph where V == IndexedPoint<Float> {
  var indexGraph: [[Int]] {
    sorted { $0.0.index < $1.0.index }
      .map { $0.1.sorted { $0.index < $1.index }}
      .map { $0.map { $0.index } }
  }
}

public func weightDistanceMatrix<T: MatrixScalar>(
  from points: [Point<T>],
  distance: (Point<T>, Point<T>) -> T) -> SymmetricBandMatrix<T>
{
  var matrix = SymmetricBandMatrix<T>(bandwidth: points.count, width: points.count)
  for i in points.indices {
    for j in i..<points.count {
      matrix[i, j] = distance(points[i], points[j])
    }
  }
  return matrix
}

public func radialBaseFunction<T: BinaryFloatingPoint>(theta: T) -> (Point<T>, Point<T>) -> T {
  { p1, p2 in T(exp(Double(-p1.distance(to: p2) / (2 * theta * theta)))) }
}

public func kmeans<Scalar: MatrixScalar>(points: [Point<Scalar>], k: Int, maxIter iter: Int = 100) -> [Set<Point<Scalar>>] {
  assert(k > 0)
  if points.count < k { return [] }
  
  var centroids = [Point<Scalar>]()
  var groups: [Set<Point<Scalar>>]!
  
  // select k random points as initial centroids
  for _ in 0..<k {
    centroids.append(points.randomElement()!)
  }
  
  for _ in 0..<iter {
    groups = [Set<Point<Scalar>>](repeating: .init(), count: k)
    
    // assign each point to the nearest centroid
    for point in points {
      let nearest = centroids
        .enumerated()
        .map { ($0, $0.1.distance(to: point)) }
        .min { $0.1 < $1.1 }!.0
      groups[nearest.0].insert(point)
    }
    
    // update centroids
    for (j, group) in groups.enumerated() {
      let centroid: Point<Scalar> = group.reduce(Point(x: 0, y: 0)) { Point(x: $0.x + $1.x, y: $0.y + $1.y) } / Scalar(group.count)
      centroids[j] = centroid
    }
  }
  
  return groups
}

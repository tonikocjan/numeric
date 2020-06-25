//
//  KDTree.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 28/03/2020.
//

import Foundation

public indirect enum KDTree<T> {
  case node(point: T, left: KDTree<T>, right: KDTree<T>)
  case leaf(point: T)
  case empty
}

public extension KDTree {
  init<C: Collection>(points: C, comparator: (T, T) -> Bool) where C.Element == T {
    guard !points.isEmpty else {
      self = .empty
      return
    }
    guard points.count > 1 else {
      self = .leaf(point: points.first!)
      return
    }
    let points = points.sorted(by: comparator)
    let n2 = (points.count - 1) / 2
    let median = points[n2]
    self = .node(point: median,
                 left: .init(points: points[0..<n2], comparator: comparator),
                 right: .init(points: points[(n2 + 1)...], comparator: comparator))
  }
  
  init<C: Collection>(points: C) where C.Element == T, T: Comparable {
    self.init(points: points, comparator: <)
  }
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible
extension KDTree: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    toString(self, indent: 0)
  }
  
  public var debugDescription: String { description }
  
  private func toString(_ tree: KDTree, indent: Int) -> String {
    func withIndent(_ string: String, indent: Int) -> String { String(repeating: " ", count: indent) + string }
    
    switch tree {
    case .empty:
      return ""
    case let .leaf(point):
      return withIndent("\\--" + String(describing: point), indent: indent)
    case let .node(point, .empty, .empty):
      return withIndent("\\--" + String(describing: point), indent: indent)
    case let .node(point, left, right):
      return withIndent("\\--" + String(describing: point), indent: indent)
        + "\n|" + toString(left, indent: indent + 4) + "\n|"
        + toString(right, indent: indent + 4)
    }
  }
}


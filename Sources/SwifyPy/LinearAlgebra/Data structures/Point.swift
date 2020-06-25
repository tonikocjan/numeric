//
//  Point.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 28/03/2020.
//

import Foundation

public struct Point<T: MatrixScalar> {
  public let x: T
  public let y: T
  
  public init(x: T, y: T) {
    self.x = x
    self.y = y
  }
}

public extension Point {
  func distance(to point: Point) -> T {
    let deltaX = self.x - point.x
    let deltaY = self.y - point.y
    return sqrt(deltaX * deltaX + deltaY * deltaY)
  }
  
  static func /(p1: Point, scalar: T) -> Point {
    Point(x: p1.x / scalar, y: p1.y / scalar)
  }
}

// MARK: - Hashable
extension Point: Hashable {}

// MARK: - Comparable
extension Point: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.x < rhs.x && lhs.y < rhs.y
  }
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible
extension Point: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { "(x: \(x), y: \(y))" }
  public var debugDescription: String { description }
}

public struct IndexedPoint<T: MatrixScalar> {
  let index: Int
  let point: Point<T>
}

public extension IndexedPoint {
  var x: T { point.x }
  var y: T { point.y }
  
  func distance(to point: IndexedPoint) -> T {
    let deltaX = self.x - point.x
    let deltaY = self.y - point.y
    return sqrt(deltaX * deltaX + deltaY * deltaY)
  }
}

// MARK: - Hashable
extension IndexedPoint: Hashable {}

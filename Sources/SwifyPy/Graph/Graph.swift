//
//  Graph.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 28/03/2020.
//

import Foundation

public struct Graph<V: Hashable> {
  private var adjancencyMatrix: [V: Set<V>]
  
  public init() {
    adjancencyMatrix = [:]
  }
  
  public init(edges: [(from: V, to: V)], isDirected: Bool) {
    self.init()
    for edge in edges {
      addEdge(from: edge.from, to: edge.to, isDirected: isDirected)
    }
  }
}

// MARK: - Public API
public extension Graph {
  mutating func addNode(_ node: V) {
    adjancencyMatrix[node] = .init()
  }
  
  mutating func addEdge(from: V, to: V, isDirected: Bool) {
    if !containsNode(from) {
      addNode(from)
    }
    if !containsNode(to) {
      addNode(to)
    }
    
    adjancencyMatrix[from]!.insert(to)
    
    if !isDirected {
      adjancencyMatrix[to]!.insert(from)
    }
  }
  
  func containsNode(_ node: V) -> Bool {
    adjancencyMatrix[node] != nil
  }
  
  func containsEdge(from: V, to: V) -> Bool {
    adjancencyMatrix[from]?.contains(to) ?? false
  }
  
  func neighbours(of vertex: V) -> Set<V>? {
    adjancencyMatrix[vertex]
  }
  
  var edgesCount: Int { reduce(0) { $0 + $1.neighbours.count } }
}

// MARK: - Collection
extension Graph: Collection {
  public typealias Index = Dictionary<V, Set<V>>.Index
  
  public subscript(position: Index) -> (node: V, neighbours: Set<V>) {
    let element = adjancencyMatrix[position]
    return (element.key, element.value)
  }
  
  public var startIndex: Index {
    adjancencyMatrix.startIndex
  }
  
  public var endIndex: Index {
    adjancencyMatrix.endIndex
  }
  
  public func index(after i: Index) -> Index {
    adjancencyMatrix.index(after: i)
  }
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible
extension Graph: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    map { node, neighbours in
      neighbours.map { neighbour in
        String(describing: node) + " --> " + String(describing: neighbour)
      }.joined(separator: "\n")
    }.joined(separator: "\n")
  }
  
  public var debugDescription: String { description }
}

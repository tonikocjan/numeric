//
//  Matrix.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

struct Matrix<T: Mathable>: MatrixProtocol, Transposable {
  typealias Value = T
  
  private class Storage {
    let width: Int
    let height: Int
    let buffer: UnsafeMutablePointer<Vector<T>>
    
    init(width: Int, height: Int) {
      self.width = width
      self.height = height
      self.buffer = .allocate(capacity: height)
    }
    
    var copy: Storage {
      print("Creating a copy of Matrix<Vector<\(type(of: T.self))>>")
      let storage = Storage(width: width, height: height)
      for i in 0..<height {
        storage.buffer.advanced(by: i).initialize(to: self.buffer.advanced(by: i).pointee)
      }
      return storage
    }
  }
  private var storage: Storage
  
  init(width: Int, height: Int) {
    self.storage = Storage(width: width, height: height)
    for i in 0..<height {
      storage.buffer.advanced(by: i).initialize(to: .init(size: width))
    }
  }
  
  init(arrayLiteral elements: Vector<T>...) {
    self.init(arrayLiteral: elements)
  }
  
  init(arrayLiteral elements: [Vector<T>]) {
    self.storage = Storage(width: elements.first?.count ?? 0, height: elements.count)
    for (i, el) in elements.enumerated() {
      storage.buffer.advanced(by: i).initialize(to: el)
    }
  }
}

private extension Matrix {
  // copy-on-write
  private var storageForWriting: Storage {
    mutating get {
      if !isKnownUniquelyReferenced(&storage) {
        self.storage = storage.copy
      }
      return storage
    }
  }
}

// MARK: - API
extension Matrix {
  var width: Int { storage.width }
  var height: Int { storage.height }
  
  subscript(_ i: Int, _ j: Int) -> T {
    get {
      assert(j >= 0)
      assert(j < width)
      return self[i][j]
    }
    mutating set {
      assert(j >= 0)
      assert(j < width)
      self[i][j] = newValue
    }
  }
  
  var transposed: Self {
    var transposed = Matrix(width: height, height: width)
    for i in 0..<height {
      for j in 0..<width {
        transposed[j, i] = self[i, j]
      }
    }
    return transposed
  }
  
  mutating func swap(row: Int, col: Int) {
    let tmp = storage.buffer[row]
    storage.buffer.advanced(by: row).initialize(to: storage.buffer.advanced(by: col).pointee)
    storage.buffer.advanced(by: col).initialize(to: tmp)
  }
  
  static func identity(_ size: Int) -> Self {
    (0..<size).map {
      var vec = Vector<T>.zeros(size)
      vec[$0] = 1
      return vec
    }
  }
  
  static func zeros(width: Int, height: Int) -> Self {
    (0..<height).map { _ in .zeros(width) }
  }
  
  static func ones(width: Int, height: Int) -> Self {
    (0..<height).map { _ in .ones(width) }
  }
}

// MARK: - Equatable
extension Matrix: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    guard lhs.shape == rhs.shape else { return false }
    return zip(lhs, rhs).first { $0 != $1 } == nil
  }
}

// MARK: - Collection
extension Matrix: BidirectionalCollection {
  subscript(_ i: Int) -> Vector<T> {
    get {
      assert(i >= 0)
      assert(i < height)
      return storage.buffer[i]
    }
    mutating set {
      assert(i >= 0)
      assert(i < height)
      storageForWriting.buffer.advanced(by: i).assign(repeating: newValue, count: 1)
    }
  }
}

// MARK: - CustomDebugStringConvertible
extension Matrix: CustomDebugStringConvertible where Value: LosslessStringConvertible {
  var debugDescription: String {
    "[" + map { $0.description }.joined(separator: "\n") + "]"
  }
}

// MARK: - CustomStringConvertible
extension Matrix: CustomStringConvertible where T: LosslessStringConvertible {
  var description: String { debugDescription }
}

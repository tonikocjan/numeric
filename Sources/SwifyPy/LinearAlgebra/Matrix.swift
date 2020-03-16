//
//  Matrix.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

public struct Matrix<T: Mathable>: MatrixProtocol, Transposable {
  public typealias Value = T
  
  var storage: COWStorage<Vector<T>, (width: Int, height: Int)>
  
  public init(width: Int, height: Int) {
    self.storage = .init(capacity: height,
                         size: (width: width, height: height),
                         provider: Vec.init)
    for i in 0..<height {
      storage.buffer.advanced(by: i).initialize(to: .init(size: width))
    }
  }
  
  public init(arrayLiteral elements: Vector<T>...) {
    self.init(arrayLiteral: elements)
  }
  
  public init(arrayLiteral elements: [Vector<T>]) {
    self.storage = .init(elements: elements,
                         size: (width: elements.first?.count ?? 0,
                                height: elements.count))
  }
}

// MARK: - SupportsCopyOnWrite
extension Matrix: SupportsCopyOnWrite {
  typealias Pointee = Vector<T>
  typealias U = (width: Int, height: Int)
}

// MARK: - Initializable
extension Matrix: DefaultValueInitializable {
  public init(_ value: Value, width: Int, height: Int) {
    self.init(arrayLiteral: .init(repeating: .repeating(width, value: value),
                                  count: height))
  }
}

// MARK: - API
public extension Matrix {
  var width: Int { storage.size!.width }
  var height: Int { storage.size!.height }
  
  subscript(_ i: Int, _ j: Int) -> T {
    get {
      assert(i >= 0)
      assert(i < height)
      return self[i][j]
    }
    mutating set {
      assert(i >= 0)
      assert(i < height)
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
}

// MARK: - Equatable
extension Matrix: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    guard lhs.shape == rhs.shape else { return false }
    return zip(lhs, rhs).allSatisfy(==)
  }
}

// MARK: - Collection
extension Matrix: BidirectionalCollection {
  public subscript(_ i: Int) -> Vector<T> {
    get {
      assert(i >= 0)
      assert(i < height)
      return storage.buffer[i]
    }
    mutating set {
      assert(i >= 0)
      assert(i < height)
      storageForWriting.buffer.advanced(by: i).initialize(to: newValue)
    }
  }
}

// MARK: - CustomDebugStringConvertible
extension Matrix: CustomDebugStringConvertible where Value: LosslessStringConvertible {
  public var debugDescription: String {
    "[" + map { $0.description }.joined(separator: "\n") + "]"
  }
}

// MARK: - CustomStringConvertible
extension Matrix: CustomStringConvertible where T: LosslessStringConvertible {
  public var description: String { debugDescription }
}

//
//  cow.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 10/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

protocol SupportsCopyOnWrite {
  associatedtype Pointee
  associatedtype U
  typealias COW = COWStorage<Pointee, U>
  var storage: COW { get set }
}

extension SupportsCopyOnWrite {
  var storageForWriting: COW {
    mutating get {
      if !isKnownUniquelyReferenced(&storage) {
        self.storage = storage.copy
      }
      return storage
    }
  }
}

class COWStorage<Pointee, T> {
  let capacity: Int
  let size: T? // ??
  let buffer: UnsafeMutablePointer<Pointee>
  
  init(capacity: Int, size: T? = nil, provider: ((Int) -> Pointee)?) {
    self.capacity = capacity
    self.size = size
    self.buffer = .allocate(capacity: capacity)
    guard let provider = provider else { return }
    for i in 0..<capacity {
      self.buffer.advanced(by: i).initialize(to: provider(i))
    }
  }
  
  init(elements: [Pointee], size: T? = nil) {
    self.capacity = elements.count
    self.size = size
    self.buffer = .allocate(capacity: capacity)
    for (i, el) in elements.enumerated() {
      self.buffer.advanced(by: i).initialize(to: el)
    }
  }
  
  init(other: COWStorage) {
    self.capacity = other.capacity
    self.size = other.size
    self.buffer = .allocate(capacity: capacity)
    for i in 0..<capacity {
      self.buffer.advanced(by: i).initialize(to: other[i])
    }
  }
}

extension COWStorage: Collection {
  var startIndex: Int { 0 }
  var endIndex: Int { capacity }
  func index(after i: Int) -> Int { i + 1 }
  
  subscript(_ index: Int) -> Pointee {
    get { buffer[index] }
    set { buffer[index] = newValue }
  }
}

extension COWStorage {
  var copy: COWStorage {
//    print("Creating a copy of \(type(of: self))")
    return COWStorage(other: self)
  }
}

extension COWStorage: Equatable where Pointee: Equatable, T: Equatable {
  static func ==(_ lhs: COWStorage, _ rhs: COWStorage) -> Bool {
    guard lhs.capacity == rhs.capacity, lhs.size == rhs.size else { return false }
    return zip(lhs, rhs).allSatisfy(==)
  }
}

extension COWStorage where T == Void {
  convenience init(capacity: Int, provider: ((Int) -> Pointee)?) {
    self.init(capacity: capacity, size: nil, provider: provider)
  }
}

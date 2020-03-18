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
        // if storage is not uniquely referenced, create a new copy
        self.storage = storage.copy
      }
      return storage
    }
  }
}

/**
 # Copy-On-Write
 
 Copy-on-write is a mechanism for deferring copying of data until an instance mutates the data.
 
 Value types require a lot of copying, since assigning a value or passing it on as a function parameter creates a copy.
 While the compiler tries to be smart about this and avoid copies when it can prove it’s safe to do so, there’s another
 optimization the author of a value type can make, and that’s to implement the type using a technique called copy-on-write.
 This is especially important for types that can hold large amounts of data, like the standard library’s collection types
 (Array, Dictionary, Set, and String). They are all implemented using copy-on-write.”

 Excerpt From: Chris Eidhof. “Advanced Swift”. Apple Books.
 
 
 This is an implementation detail and is hidden from the users of this library.
 */
class COWStorage<Pointee, T> {
  /// The capacity of this buffer: sizeof(Pointee) * capacity
  let capacity: Int
  
  /// Any additional size information, for instance Matrix requires both `width` and `height`.
  let size: T?
  
  /// The actual buffer containing data.
  let buffer: UnsafeMutablePointer<Pointee>
  
  /**
   Initialize a new buffer.
   
   - Parameters:
       - capacity: number of `Pointee`s in the buffer
       - size: Any additional information required or `nil` if not required.
       - provider: A function which, given an index of the current elemenent, generates buffer element (Pointee).
   If not required, set to `nil`.
   */
  init(capacity: Int, size: T? = nil, provider: ((Int) -> Pointee)?) {
    self.capacity = capacity
    self.size = size
    self.buffer = .allocate(capacity: capacity)
    guard let provider = provider else { return }
    for i in 0..<capacity {
      self.buffer.advanced(by: i).initialize(to: provider(i))
    }
  }
  
  /**
   Initialize a new buffer from the givene `elements`.
   
   - Parameters:
       - elements: Items of this buffer. `capacity` will equal to `elements.count`
       - size: Any additional information required or `nil` if not required.
   */
  init(elements: [Pointee], size: T? = nil) {
    self.capacity = elements.count
    self.size = size
    self.buffer = .allocate(capacity: capacity)
    for (i, el) in elements.enumerated() {
      self.buffer.advanced(by: i).initialize(to: el)
    }
  }
  
  /**
   Initialize a new buffer by making a copy of an existing buffer.
   
   - Parameter other: The buffee from which a copy is made.
   */
  init(other: COWStorage) {
    self.capacity = other.capacity
    self.size = other.size
    self.buffer = .allocate(capacity: capacity)
    for i in 0..<capacity {
      self.buffer.advanced(by: i).initialize(to: other[i])
    }
  }
  
  deinit {
    buffer.deallocate()
  }
}

// MARK: - Collection
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

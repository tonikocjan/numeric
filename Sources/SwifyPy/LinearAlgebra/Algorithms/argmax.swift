//
//  argmax.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 17/03/2020.
//

import Foundation

/// Find the largest element in the vector starting from `from`
/// and return it's index or `nil` if vector is empty.
func argmax<T: MatrixScalar>(_ v: Vector<T>, from: Int = 0) -> Int? {
  argmax(v, from: from, to: v.count)
}

/// Find the largest element in the vector starting from `from` stoping at `to`
/// and return it's index or `nil` if vector is empty.
func argmax<T: MatrixScalar>(_ v: Vector<T>, from: Int, to: Int) -> Int? {
  guard !v.isEmpty else { return nil }
  
  assert(from >= 0)
  assert(from < to)
  assert(to < v.count)
  var idx = from
  var max = v[from]
  for i in (1..<to) {
    if max < v[i] {
      idx = i
      max = v[i]
    }
  }
  return idx
}

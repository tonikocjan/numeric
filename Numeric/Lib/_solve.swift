//
//  _solve.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

func argmax<T: Mathable>(_ v: Vector<T>, from: Int = 0) -> Int {
  assert(from < v.count)
  assert(from >= 0)
  var idx = from
  var max = v[from]
  for i in (1..<v.count) {
    if max < v[i] {
      idx = i
      max = v[i]
    }
  }
  return idx
}

func _solve<M: MatrixProtocol>(_ a: M, _ v: Vector<M.Value>) -> Vector<M.Value> {
  assert(a.width == a.height)
  
  var a = a
  var v = v
  let n = a.width

  for i in 0..<(n - 1) {
    for j in (i + 1)..<n {
      let l = a[j, i] / a[i, j]
      for k in j..<n {
        a[i + 1, k] = a[i + 1, k] - l * a[i, k]
      }
      v[i + 1] = v[i + 1] - l * v[i]
    }
    
    print("Iter", i)
    print(a)
    print(v)
    print()
  }
  
  return v
}

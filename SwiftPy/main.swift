//
//  main.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

let vec: Vector = [1, -6, -17, -52]

let m: Matrix = [
  [4, 2, 1, 0, 0, 0],
  [4, 12, 7, 1, 0, 0],
  [-5, 1, 10, 1, 1, 0],
  [0, -1, 1, 8, 2, 3],
  [0, 0, 1, 4, 6, -1],
  [0, 0, 0, 4, 5, 10]
]
//print(LUDecomposition(m))

let band: BandMatrix = [
  [4, 2, 1],
  [4, 12, 7, 1],
  [-5, 1, 10, 1, 1],
  [-1, 1, 8, 2, 3],
  [1, 4, 6, -1],
  [4, 5, 10]
]
var (L, U) = LUDecomposition(band)
//print(L, "\n\n", U)
//print()

let band2: BandMatrix = [
  [3, 2],
  [-4, 7, 8],
  [4, 13, 1],
  [5, 15]
]
let v: Vector = [1, 2, 3, 4]
let x = v !/ band2
print(x)
print(band2 * x)

//print()
//print(L, "\n", U)

let m2: Matrix = [
  [3, 2, 0, 0],
  [-4, 7, 8, 0],
  [0, 4, 13, 1],
  [0, 0, 5, 15]
]

print(v !/ m2)
print(band2 * (v !/ m2))
print(m2 * (v !/ m2))
//LUDecomposition(m2)
//print(LU_ITERATIONS_COUNT)

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
LUDecomposition(m)
print(LU_ITERATIONS_COUNT)

let band: BandMatrix = [
  [4, 2, 1],
  [4, 12, 7, 1],
  [-5, 1, 10, 1, 1],
  [-1, 1, 8, 2, 3],
  [1, 4, 6, -1],
  [4, 5, 10]
]
var (L, U) = band.LUDecomposition()
print(LU_ITERATIONS_COUNT)
//print(L, "\n\n", U)
//print()

let band2: BandMatrix = [
  [3, 2],
  [-4, 7, 8],
  [4, 13, 1],
  [5, 15]
]
(L, U) = band2.LUDecomposition()
print(LU_ITERATIONS_COUNT)
//print()
//print(L, "\n", U)

let m2: Matrix = [
  [3, 2, 0, 0],
  [-4, 7, 8, 9],
  [0, 4, 13, 1],
  [0, 0, 5, 15]
]
LUDecomposition(m2)
print(LU_ITERATIONS_COUNT)

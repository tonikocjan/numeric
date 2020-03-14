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
  [3, 2, 0, 0],
  [-4, 7, 8, 0],
  [0, 4, 13, 1],
  [0, 0, 5, 15]
]
print(LUDecomposition(m))

print()

let band: BandMatrix = [
  [3, 2],
  [-4, 7, 8],
  [4, 13, 1],
  [5, 15]
]
let (L, U) = band.LUDecomposition()
print(L, "\n", U)

//
//  main.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

let vec: Vector = [1, -6, -17, -52]

let band: BandMatrix = [
  [3, 2, 5],
  [6, 6, 15, 3],
  [-3, 4, 13, 1],
  [-6, 6, 15]
]
print(vec !/ band)

let mat: Matrix = [
  [3, 2, 5, 0],
  [6, 6, 15, 3],
  [-3, 4, 13, 1],
  [0, -6, 6, 15]
]

print(vec !/ mat)

print(band == mat)

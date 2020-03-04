//
//  main.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

var matrix: Matrix = [
  [3, 4, 1],
  [5, 5, 1],
  [-2, 2, 4]
]

print(matrix)

print(matrix[0])
print(matrix[0, 0])

print(matrix !/ [6, 6, 10])

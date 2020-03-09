//
//  main.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

var matrix: Matrix = [
  [3, 2, 5, 1],
  [6, 6, 15, 3],
  [-3, 4, 13, 1],
  [-6, 6, 15, 5]
]

for i in 0..<100 {
  
  //
  //print(matrix !/ [6, 6, 10, 1])
  
  matrix[0, 1] = 20
//  print(matrix)
  
}

var m2 = matrix
m2[0,0] = 100


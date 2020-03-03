//
//  main.swift
//  Numeric
//
//  Created by Toni Kocjan on 03/03/2020.
//  Copyright © 2020 TSS. All rights reserved.
//

import Foundation

var matrix: Matrix = [
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9]
]

print(matrix)

print(matrix[0])
print(matrix[0, 0])

func test<M: MatrixProtocol>(_ m: M) {
  m[10]
}

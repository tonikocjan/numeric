//
//  DefaultValueInitializable.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 16/03/2020.
//

import Foundation

protocol DefaultValueInitializable where Self: MatrixProtocol {
  init(_ value: Value, width: Int, height: Int)
}

extension DefaultValueInitializable {
  static func zeros(width: Int, height: Int) -> Self {
    .init(0, width: width, height: height)
  }
  
  static func ones(width: Int, height: Int) -> Self {
    .init(1, width: width, height: height)
  }
}

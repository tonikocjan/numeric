//
//  curry.swift
//  SwifyPy
//
//  Created by Toni Kocjan on 08/04/2020.
//

import Foundation

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  { A in
    { B in
      f(A, B)
    }
  }
}

public func curry1<A, B, C>(_ f: @escaping (A, B) -> C) -> (B) -> (A) -> C {
  { B in
    { A in
      f(A, B)
    }
  }
}

public func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
  { A in
    { B in
      { C in
        f(A, B, C)
      }
    }
  }
}

public func curry1<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (B) -> (C) -> (A) -> D {
  { B in
    { C in
      { A in
        f(A, B, C)
      }
    }
  }
}

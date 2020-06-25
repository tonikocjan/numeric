//
//  EigenTests.swift
//  SwifyPyTests
//
//  Created by Toni Kocjan on 26/03/2020.
//

import XCTest
@testable import SwifyPy

class EigenTests: XCTestCase {
  override class func setUp() {
    setenv("PYTHON_LIBRARY", "/usr/local/bin/python3", 1)
  }
  
  func test1() {
    var A: Matrix =
      [[0.7684476751965699,0.6625548164736534,0.16366581948600145,0.46384720826189474,0.7058603316467515,],
       [0.940515000715187,0.5860221243068029,0.4730168160953825,0.2758191151428051,0.29197826680025996,],
       [0.6739586945680673,0.05213316316865657,0.8654121434083455,0.44656806533266313,0.2810658951014575,],
       [0.3954531123351086,0.26863956854495097,0.617491887982287,0.5823177800870469,0.7929310291631577,],
       [0.3132439558075186,0.10887074134844155,0.2856979003853177,0.2559813032181608,0.2092301681102957,],]
    
    A = A + A.transposed
    let (eigenValues, eigenVectors) = eigen(A, vectors: true, maxIter: 500)
    validateEigen((eigenValues, eigenVectors), A)
  }
  
  func test2() {
    let A: Matrix =
      [[1.54, 1.60, 0.84, 0, 0],
       [1.60, 1.17, 0.53, 0.54, 0],
       [0.84, 0.53, 1.73, 1.06, 0.57],
       [0, 0.54, 1.06, 1.16, 1.05],
       [0, 0, 0.57, 1.05, 0.42]]
    let (eigenValues, eigenVectors) = eigen(A, vectors: true, maxIter: 500)
    validateEigen((eigenValues, eigenVectors), A)
  }
  
  func testSymBand1() {
    let S: SymmetricBandMatrix =
      [[1.54, 1.17, 1.73, 1.16, 0.42],
       [1.60, 0.53, 1.06, 1.05],
       [0.84, 0.54, 0.57]]
    validateEigen(eigen(S, vectors: true), S, accuracy: 10e-2)
  }
  
  @available(OSX 10.11, *)
  func test25x25() {
    let w = 25
    var A = randn(shape: (w, w), generator: randnGenerator(mean: 0, deviation: 10, seed: 123))
    A = A + A.transposed
    let (vals, vecs) = eigen(A, vectors: true, maxIter: 100)
    XCTAssertGreaterThan(0.05, compareEigens(A, vals, vecs!).avg)
  }
  
  @available(OSX 10.11, *)
  func test21x21Laplace() {
    let L = laplaceMatrix(m: 7)
    let (vals, vecs) = eigen(L, vectors: true, eps: 10e-8)
    XCTAssertGreaterThan(0.05, compareEigens(L, vals, vecs!).avg)
  }
  
  @available(OSX 10.11, *)
  func test30x30Laplace() {
    let L = laplaceMatrix(m: 10)
    let (vals, vecs) = eigen(L, vectors: true, eps: 10e-8)
    XCTAssertGreaterThan(0.05, compareEigens(L, vals, vecs!).avg)
  }
}

///

func validateEigen<M: MatrixProtocol>(_ input: (Vector<M.Scalar>, Matrix<M.Scalar>?), _ A: M, accuracy: M.Scalar = 10e-2) {
  let (v, Q) = input
  for i in 0..<Q!.width {
    let eigenVec = Q![0..., i]
    XCTAssertEqual(A * eigenVec, v[i] * eigenVec, accuracy: accuracy)
  }
}

func compareEigens<M: MatrixProtocol>(_ A: M, _ vals: Vector<M.Scalar>, _ vecs: Matrix<M.Scalar>) -> Vector<M.Scalar> {
  var diffs = [M.Scalar]()
  for (val, vec) in zip(vals, vecs.columnMap { $0 }) {
    diffs.append((A * vec - val * vec).sum)
  }
  return .init(arrayLiteral: diffs)
}

@available(OSX 10.11, *)
func laplaceMatrix(m: Int) -> SymmetricBandMatrix<Float> {
  let generator = randnGenerator(mean: 0, deviation: 1, seed: 12)
  let x = [1 + randn(count: m, generator: generator),
           -3 + randn(count: m, generator: generator),
           randn(count: m, generator: generator)]
    .flatMap { $0 }
  let y = [-2 + randn(count: m, generator: generator),
           -1 + randn(count: m, generator: generator),
           1 + randn(count: m, generator: generator)]
    .flatMap { $0 }

  let points = zip(x, y).map(Point.init)
  let graph = similarityGraph(from: points, eps: 0.9).indexGraph
  let laplace = LaplaceMatrix(graph: graph) * Matrix<Float>.identity(graph.count)
  var upper = UpperBandMatrix<Float>(bandwidth: graph.count / 3, size: graph.count)
  for i in 0..<graph.count {
    for j in i..<Swift.min(i + upper.bandwidth, graph.count) {
      upper[i, j] = laplace[i, j]
    }
  }
  return SymmetricBandMatrix(upper)
}

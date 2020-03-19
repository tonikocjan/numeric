# Numerical Mathematics


## Homework assignment 1

As part of the first assignment, we were tasked to implement a couple of data structures for sparse matrices (Linear Algebra):

1. BandMatrix
2. UpperBandMatrix
3. LowerBandMatrix

A **band matrix** is a sparse matrix whose non-zero entries are confined to a diagonal band, comprising the main diagonal and zero or more diagonals on either side.

Similarily, **upper band** and **lower band** matrices contain non-zero diagonals only on the main diagonal and zero or more diagonals above or below the main diagonal, respectively.

Each data structure should contain some algebraic operations and algorithms:

1. Accessing and mutating elements by index (subscripts).
2. Multiplication of matrix with a vector.
3. _Division_ from the left (solving linear systems of equations).
4. LU decomposition of a matrix.

Taking advantage of the fact that these matrices are sparse we should provide optimized versions of algorithms.

Additionally, to make our library more complete, we provide some supplementary data structures and operations on them which are essential for any linear algebra library.

### Project structure

```
├── README.md
├── Sources
│   ├── SwifyPy
│   │   └── Time
│   │       └── time.swift
│   │   ├── Python
│   │   │   └── Python.swift
│   │   ├── CopyOnWrite
│   │   │   └── cow.swift
│   │   ├── LinearAlgebra
│   │   │   ├── Protocols
│   │   │   │   ├── DefaultValueInitializable.swift
│   │   │   │   ├── MatrixProtocol.swift
│   │   │   │   └── Transposable.swift
│   │   │   ├── Algorithms
│   │   │   │   ├── LUDecomposition.swift
│   │   │   │   ├── Laplace2D.swift
│   │   │   │   └── argmax.swift
│   │   │   └── Vector.swift
│   │   │   ├── Matrix.swift
│   │   │   ├── BandMatrix.swift
│   │   │   ├── UpperBandMatrix.swift
│   │   │   ├── LowerBandMatrix.swift
│   └── SwifyPyRun
│       └── main.swift
├── Tests
│   ├── LinuxMain.swift
│   └── SwifyPyTests
│       ├── BandMatrixTests.swift
│       ├── LUSolverTests.swift
│       ├── Laplace2DTests.swift
│       ├── LowerBandMatrixTests.swift
│       ├── MatrixTests.swift
│       ├── UpperBandMatrixTests.swift
│       ├── VectorTests.swift
│       └── XCTestManifests.swift
└── docs
```

### Solving the boundary problem for Laplace equation in 2D

To validate our implementation, we compute the approximate solution to the boundary problem for the Laplace equation in 2D inside the rectangle bounded by `(a, b) x (c, d)`.

```swift
let (Z, x, y) = Laplace2D.solveBoundaryProblem(
  fs: sin,
  fd: neg(sin),
  fz: sin,
  fl: neg(sin),
  h: 0.075,
  bounds: ((0, .pi), (0, .pi)
)
```

We plot the output of the algorithm to obtain a 3D surface:

```swift
surface(x: x, y: y, Z: Z)
```

and obtain:

![milnica](milnica.png)

For drawing, we use Python's awesome `matplotlib` library. To do that, we integrate [PythonKit](https://github.com/pvieito/PythonKit) Swift library.

## Building and running the project

1. Clone the repository: 

	```
	> git clone https://gitlab.com/nummat/nummat-1920.git
	```

2. Make sure Swift 5.1 is installed:

	```
	> swift --version
	  Apple Swift version 5.1.3 (swiftlang-1100.0.282.1 clang-1100.0.33.15)
	  Target: x86_64-apple-darwin19.3.0
	
	on macOS
	
	or
	
	  Swift version 5.1.5 (swift-5.1.5-RELEASE)
	  Target: x86_64-unknown-linux-gnu
	
	on Ubuntu (Linux)
	```

	If you don't have Swift installed follow [Linux installation guidlines](https://itsfoss.com/use-swift-linux/).

3. Build and run (or test):

	```
	> cd src/Dn1-toni/Numeric/
	> swift build -c release
	> swift run -c release
	> swift test
	```
	
## Base repository

https://gitlab.com/seckmaster/numeric

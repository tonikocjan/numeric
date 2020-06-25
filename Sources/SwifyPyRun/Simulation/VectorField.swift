//
//  VectorField.swift
//  SwifyPyRun
//
//  Created by Toni Kocjan on 17/05/2020.
//

import AppKit
import SwifyPy

enum VectorFieldType {
  case direction, acceleration
}

class VectorField: NSView {
  let xAxis: [CGFloat]
  let yAxis: [CGFloat]
  
  var vectorField: VectorFieldType? = .direction { didSet { needsDisplay = true } }
  
  var L: Double = 1 { didSet { needsDisplay = true } }
  var mu: Double = 0 { didSet { needsDisplay = true } }
  var G: Double = 9.80665 { didSet { needsDisplay = true } }
  
  init(xAxis: [CGFloat], yAxis: [CGFloat]) {
    self.xAxis = xAxis
    self.yAxis = yAxis
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ dirtyRect: NSRect) {
    drawGrid(dirtyRect)
    drawVectorField(dirtyRect)
  }
}

extension VectorField {
  /// Convert point from `theta-dtheta` to `screen-space` coordinate system.
  func convertTo(_ point: NSPoint) -> NSPoint {
    NSPoint(
      x: (point.x * (frame.width * 0.5 / xAxis.max()!)) + frame.width * 0.5,
      y: (point.y * (frame.height * 0.5 / yAxis.max()!)) + frame.height * 0.5
    )
  }
  
  /// Convert point from `screen-space` to `theta-dtheta` coordinate system.
  func convertFrom(_ point: NSPoint) -> NSPoint {
    NSPoint(
      x: (point.x - frame.width * 0.5) / (frame.width * 0.5 / xAxis.max()!),
      y: (point.y - frame.height * 0.5) / (frame.height * 0.5 / yAxis.max()!)
    )
  }
}

private extension VectorField {
  func drawGrid(_ dirtyRect: NSRect) {
    let width = dirtyRect.width / CGFloat(xAxis.count - 1)
    let height = dirtyRect.height / CGFloat(yAxis.count - 1)
    
    let originX = xAxis.count / 2
    let originY = yAxis.count / 2
    
    for (i, x) in xAxis.dropLast().enumerated() {
      let xPoint = CGFloat(i) * width
      drawLine(
        .init(x: xPoint, y: 0),
        .init(x: xPoint, y: CGFloat(yAxis.count) * height),
        i == originX ? NSColor.black : NSColor.black.withAlphaComponent(0.1),
        i == originX ? 2 : 1
      )
      withVaList([x]) { NSString(format: "%.2f", arguments: $0) }.draw(at: .init(x: xPoint - 15, y: dirtyRect.midY - 20), withAttributes: [.font: NSFont.systemFont(ofSize: 14)])
    }
    
    for (j, y) in yAxis.dropLast().enumerated() {
      let yPoint = CGFloat(j) * height
      drawLine(
        .init(x: 0, y: yPoint),
        .init(x: CGFloat(xAxis.count) * width, y: yPoint),
        j == originY ? NSColor.black : NSColor.black.withAlphaComponent(0.1),
        j == originY ? 2 : 1
      )
      withVaList([y]) { NSString(format: "%.2f", arguments: $0) }.draw(at: .init(x: dirtyRect.midX - 40, y: yPoint - 10), withAttributes: [.font: NSFont.systemFont(ofSize: 14)])
    }
  }
  
  func drawVectorField(h: CGFloat = 0.4, _ dirtyRect: NSRect) {
    for theta in stride(from: xAxis.min()!, through: xAxis.max()!, by: h) {
      for dtheta in stride(from: yAxis.min()!, through: yAxis.max()!, by: h) {
        let startPoint = convertTo(.init(x: theta, y: dtheta))
        let endPoint: CGPoint
        
        switch vectorField {
        case .direction?:
          let (theta2, dtheta2) = Pendulum.simulate(G: G, L: L, theta: Double(theta), dtheta: Double(dtheta), μ: mu, time: 0.05, n: 10)
          endPoint = convertTo(NSPoint(x: theta2, y: dtheta2))
        case .acceleration?:
          endPoint = convertTo(.init(
            x: dtheta,
            y: CGFloat(Pendulum.acceleration(G: G, L: L, theta: Double(theta), dtheta: Double(dtheta), μ: mu))
          ))
        case nil:
          return
        }
        
        let vector = NSPoint(
          x: endPoint.x - startPoint.x,
          y: endPoint.y - startPoint.y)
          .normalized
        
        drawArrow(
          startPoint,
          .init(x: startPoint.x + vector.x * 10,
                y: startPoint.y + vector.y * 10),
          .orange
        )
      }
    }
  }
}

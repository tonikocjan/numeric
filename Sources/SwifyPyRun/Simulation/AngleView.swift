//
//  File.swift
//  SwifyPyRun
//
//  Created by Toni Kocjan on 18/05/2020.
//

import AppKit

class AngleView: View {
  let xAxis: [CGFloat]
  let yAxis: [CGFloat]
  
  private let h = 0.0175
  private var time = 0.0
  
  private var pendulumPath: NSBezierPath?
  var pendulumAngle: Double = 0{
    didSet {
      updatePath()
      needsDisplay = true
    }
  }
  
  private var harmonicPath: NSBezierPath?
  var harmonicAngle: Double = 0{
    didSet {
      updatePath()
      needsDisplay = true
    }
  }
  
  init() {
    self.xAxis = stride(from: 0, to: 20, by: 1).map(CGFloat.init)
    self.yAxis = stride(from: 2 * -Double.pi, through: 2 * .pi, by: .pi / 4).map { CGFloat($0) }
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ dirtyRect: NSRect) {
    drawGrid(dirtyRect)
    
    var point = convertTo(CGPoint(
      x: time,
      y: pendulumAngle))
    var path = NSBezierPath(ovalIn: .init(
      origin: .init(x: point.x - 5, y: point.y - 5),
      size: .init(width: 10, height: 10)))
    NSColor.green.setFill()
    path.fill()
    
    point = convertTo(CGPoint(
      x: time,
      y: harmonicAngle))
    path = NSBezierPath(ovalIn: .init(
      origin: .init(x: point.x - 5, y: point.y - 5),
      size: .init(width: 10, height: 10)))
    NSColor.red.setFill()
    path.fill()
    
    NSColor.green.setStroke()
    self.pendulumPath?.stroke()
    
    NSColor.red.setStroke()
    self.harmonicPath?.stroke()
  }
  
  func reset() {
    pendulumAngle = 0
    pendulumPath = nil
    harmonicAngle = 0
    harmonicPath = nil
    time = 0
  }
}

private extension AngleView {
  func updatePath() {
    time += h
    
    if pendulumPath == nil {
      pendulumPath = NSBezierPath()
      pendulumPath!.move(to: convertTo(.init(x: 0, y: 0)))
    }
    pendulumPath!.line(to: convertTo(.init(x: time, y: pendulumAngle)))
    
    if harmonicPath == nil {
      harmonicPath = NSBezierPath()
      harmonicPath!.move(to: convertTo(.init(x: 0, y: 0)))
    }
    harmonicPath!.line(to: convertTo(.init(x: time, y: harmonicAngle)))
  }
  
  func drawGrid(_ dirtyRect: NSRect) {
    let width = dirtyRect.width / CGFloat(xAxis.count - 1)
    let height = dirtyRect.height / CGFloat(yAxis.count - 1)
    
    let originX = 0
    let originY = yAxis.count / 2
    
    for (i, x) in xAxis.dropLast().enumerated() {
      let xPoint = CGFloat(i + 1) * width
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
      withVaList([y]) { NSString(format: "%.2f", arguments: $0) }.draw(at: .init(x: width, y: yPoint - 10), withAttributes: [.font: NSFont.systemFont(ofSize: 14)])
    }
  }
}

extension AngleView {
  /// Convert point from `time-theta` to `screen-space` coordinate system.
  func convertTo(_ point: NSPoint) -> NSPoint {
    let width = frame.width / CGFloat(xAxis.count - 1)
    return NSPoint(
      x: width + point.x * width,
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

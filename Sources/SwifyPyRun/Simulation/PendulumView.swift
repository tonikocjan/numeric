//
//  PendulumView.swift
//  SwifyPyRun
//
//  Created by Toni Kocjan on 09/05/2020.
//

import AppKit

class PendulumView: View {
  var theta: Double = 0 {
    didSet {
      needsDisplay = true
    }
  }
  var arrowLength: Double = 10 {
    didSet {
      needsDisplay = true
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    let angle = theta.truncatingRemainder(dividingBy: 2 * .pi)
    let angleDegrees = [abs(Int(theta * 180 / .pi)) % 360]
    
    var bezierPath = NSBezierPath()
    let dashes: [CGFloat] = [0, 4]
    
    let inset: CGFloat = 50
    let height: CGFloat = 150
    let origin = NSPoint(x: frame.midX, y: inset)
    let top = NSPoint(x: frame.midX, y: inset + height)
    
    bezierPath.move(to: origin)
    bezierPath.line(to: top)
    bezierPath.setLineDash(dashes, count: dashes.count, phase: 2)
    bezierPath.lineWidth = 2
    NSColor.white.setStroke()
    bezierPath.stroke()
    
    let c = CGFloat(cos(angle - .pi / 2))
    let s = CGFloat(sin(angle - .pi / 2))
    let bottom = NSPoint(
      x: c * height + top.x,
      y: s * height + top.y)
    drawLine(
      top,
      bottom,
      .white)
    
    bezierPath = .init()
    let pendulumOvalFrame: NSRect = .init(origin: .init(x: bottom.x - 7.5, y: bottom.y - 7.5),
                                          size: .init(width: 15, height: 15))
    
    let arriwStartPoint = CGPoint(
      x: pendulumOvalFrame.origin.x + 7.5,
      y: pendulumOvalFrame.origin.y + 7.5
    )
    let arrowEndpoint = CGPoint(
      x: Double(arriwStartPoint.x) - cos(angle) * arrowLength,
      y: Double(arriwStartPoint.y) - sin(angle) * arrowLength
    )
    drawArrow(arriwStartPoint, arrowEndpoint, .orange, 4, 15)
    
    
    bezierPath.appendOval(in: pendulumOvalFrame)
    NSColor.white.setFill()
    bezierPath.fill()
    
    bezierPath = .init()
    
    if angle > 0 {
      bezierPath.appendArc(
        withCenter: top,
        radius: 40,
        startAngle: 270,
        endAngle: 270 + CGFloat(angle * 180 / .pi),
        clockwise: false)
    } else {
      bezierPath.appendArc(
        withCenter: top,
        radius: 40,
        startAngle: 270,
        endAngle: 270 + CGFloat(angle * 180 / .pi),
        clockwise: true)
    }
    NSColor.white.setStroke()
    bezierPath.stroke()
    
    let string = withVaList(angleDegrees) { NSString(format: "%d°", arguments: $0) }
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    string.draw(in: .init(x: 10, y: 15, width: dirtyRect.width, height: 30), withAttributes: [.foregroundColor: NSColor.white, .font: NSFont.systemFont(ofSize: 25), .paragraphStyle: paragraph])
  }
}

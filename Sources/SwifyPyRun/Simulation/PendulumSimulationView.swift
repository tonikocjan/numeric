//
//  PendulumSimulationView.swift
//  SwifyPyRun
//
//  Created by Toni Kocjan on 09/05/2020.
//

import SwifyPy
import AppKit

class PendulumSimulationView: View {
  let vectorField: VectorField
  let angleView: AngleView
  let containerView = View()
  let labelTheta = NSTextField()
  let labelVelocity = NSTextField()
  let labelAcceleration = NSTextField()
  let sliderL = Slider(value: 1, minValue: 0.1, maxValue: 100, target: self, action: #selector(sliderDidChange))
  let sliderMu = Slider(value: 0, minValue: 0, maxValue: 1, target: self, action: #selector(sliderDidChange))
  let sliderG = Slider(value: 9.80665, minValue: 0, maxValue: 100, target: self, action: #selector(sliderDidChange))
  let simulateButton = NSButton(title: "Simulate", target: self, action: #selector(didTapSimulateButton))
  let toggleButton = NSButton(title: "Toggle", target: self, action: #selector(didTapToggleButton))
  let accelerationVectorFieldButton = NSButton(radioButtonWithTitle: "Acceleration field", target: nil, action: nil)
  let directionVectorFieldButton = NSButton(radioButtonWithTitle: "Direction field", target: nil, action: nil)
  let hideVectorFieldButton = NSButton(radioButtonWithTitle: "Hide", target: nil, action: nil)
  let pendulum = PendulumView()
  var displayLink: DisplayLink?
  
  var mouseOverPoint: CGPoint = .zero
  
  // 2nd derivative
  var acceleration: Double = 0 {
    didSet {
      labelAcceleration.stringValue = "θ'': \(acceleration)"
    }
  }
  // 1st derivative
  var dtheta: Double = 0 {
    didSet {
      labelVelocity.stringValue = "θ' : \(dtheta)"
    }
  }
  // theta
  var theta: Double = 0 {
    didSet {
      labelTheta.stringValue = "θ  : \(theta)"
      pendulum.theta = theta
      angleView.pendulumAngle = theta
    }
  }
  
  private var pendulumPath: NSBezierPath?
  
  init(
    xAxis: [CGFloat],
    yAxis: [CGFloat])
  {
    assert(xAxis.count % 2 != 0)
    assert(yAxis.count % 2 != 0)
    
    vectorField = .init(xAxis: xAxis, yAxis: yAxis)
    angleView = .init()
    
    super.init(frame: .zero)
    
    let options: NSTrackingArea.Options = [
      .mouseEnteredAndExited,
      .mouseMoved,
      .activeInKeyWindow
    ]
    let trackingArea = NSTrackingArea(
      rect: self.bounds,
      options: options,
      owner: self,
      userInfo: nil)
    addTrackingArea(trackingArea)
    
    addSubview(vectorField)
    addSubview(angleView)
    angleView.isHidden = true
    
    addSubview(containerView)
    containerView.backgroundColor = .systemBlue
    containerView.layer?.borderColor = NSColor.black.cgColor
    containerView.layer?.borderWidth = 1
    containerView.layer?.cornerRadius = 5
    
    labelTheta.textColor = .black
    labelTheta.font = .systemFont(ofSize: 12)
    labelTheta.backgroundColor = .white
    labelTheta.isEditable = false
    containerView.addSubview(labelTheta)
    
    labelVelocity.textColor = .black
    labelVelocity.font = .systemFont(ofSize: 12)
    labelVelocity.backgroundColor = .white
    labelVelocity.isEditable = false
    containerView.addSubview(labelVelocity)
    
    labelAcceleration.textColor = .black
    labelAcceleration.font = .systemFont(ofSize: 12)
    labelAcceleration.backgroundColor = .white
    labelAcceleration.isEditable = false
    containerView.addSubview(labelAcceleration)
    
    sliderL.action = #selector(sliderDidChange(_:))
    sliderL.target = self
    containerView.addSubview(sliderL)
    
    sliderMu.action = #selector(sliderDidChange(_:))
    sliderMu.target = self
    containerView.addSubview(sliderMu)
    
    sliderG.action = #selector(sliderDidChange(_:))
    sliderG.target = self
    containerView.addSubview(sliderG)
    
    containerView.addSubview(simulateButton)
    simulateButton.target = self
    simulateButton.action = #selector(didTapSimulateButton)
    
    containerView.addSubview(toggleButton)
    toggleButton.target = self
    toggleButton.action = #selector(didTapToggleButton)
    
    containerView.addSubview(accelerationVectorFieldButton)
    accelerationVectorFieldButton.title = "Acceleration vector field"
    accelerationVectorFieldButton.setButtonType(.radio)
    accelerationVectorFieldButton.target = self
    accelerationVectorFieldButton.action = #selector(didTapRadioButton)
    
    containerView.addSubview(directionVectorFieldButton)
    directionVectorFieldButton.setButtonType(.radio)
    directionVectorFieldButton.state = .on
    directionVectorFieldButton.title = "Direction vector field"
    directionVectorFieldButton.target = self
    directionVectorFieldButton.action = #selector(didTapRadioButton)
    
    containerView.addSubview(hideVectorFieldButton)
    hideVectorFieldButton.title = "Hide vector field"
    hideVectorFieldButton.setButtonType(.radio)
    hideVectorFieldButton.target = self
    hideVectorFieldButton.action = #selector(didTapRadioButton)
    
    addSubview(pendulum)
    pendulum.backgroundColor = NSColor.black
    
    ///
    layerContentsRedrawPolicy = .onSetNeedsDisplay
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layout() {
    super.layout()
    vectorField.frame = frame
    angleView.frame = frame
    let width: CGFloat = 300
    containerView.frame = .init(x: frame.maxX - width - 10, y: 10, width: width, height: 400)
    labelTheta.frame = .init(x: 10, y: 10, width: width - 20, height: 20)
    labelVelocity.frame = .init(x: 10, y: labelTheta.frame.maxY + 10, width: width - 20, height: 20)
    labelAcceleration.frame = .init(x: 10, y: labelVelocity.frame.maxY + 10, width: width - 20, height: 20)
    mouseOverPoint = .init(x: frame.midX, y: frame.midY)
    sliderL.frame = .init(x: 10, y: labelAcceleration.frame.maxY + 10, width: width - 20, height: 25)
    sliderMu.frame = .init(x: 10, y: sliderL.frame.maxY + 10, width: width - 20, height: 25)
    sliderG.frame = .init(x: 10, y: sliderMu.frame.maxY + 10, width: width - 20, height: 25)
    simulateButton.frame = .init(x: 10, y: sliderG.frame.maxY + 10, width: width - 20, height: 20)
    toggleButton.frame = .init(x: 10, y: simulateButton.frame.maxY + 10, width: width - 20, height: 20)
    accelerationVectorFieldButton.frame = .init(x: 10, y: toggleButton.frame.maxY + 10, width: width - 20, height: 18)
    directionVectorFieldButton.frame = .init(x: 10, y: accelerationVectorFieldButton.frame.maxY + 10, width: width - 20, height: 18)
    hideVectorFieldButton.frame = .init(x: 10, y: directionVectorFieldButton.frame.maxY + 10, width: width - 20, height: 18)
    pendulum.frame = .init(x: 10, y: frame.height - 400 - 50, width: 400, height: 400)
  }
  
  override func draw(_ dirtyRect: NSRect) {
    acceleration = Pendulum.acceleration(G: vectorField.G, L: vectorField.L, theta: theta, dtheta: dtheta, μ: vectorField.mu)
    drawMousePosition(dirtyRect)
    NSColor.red.setStroke()
    pendulumPath?.stroke()
  }
  
  override func mouseDragged(with event: NSEvent) {
    let c = coordinate(for: event.locationInWindow)
    theta = Double(c.x)
    dtheta = Double(c.y)
  }
  
  override func mouseDown(with event: NSEvent) {
    let c = coordinate(for: event.locationInWindow)
    theta = Double(c.x)
    dtheta = Double(c.y)
  }
  
  override func keyDown(with event: NSEvent) {
    switch event.characters?.first {
    case "r"?, "R"?:
      didTapSimulateButton()
    case _:
      break
    }
  }
}

private extension PendulumSimulationView {
  private func coordinate(for point: CGPoint) -> CGPoint {
    mouseOverPoint = point
    needsDisplay = true
    return vectorField.convertFrom(point)
  }
  
  @objc func sliderDidChange(_ slider: NSSlider) {
    switch slider {
    case sliderL:
      vectorField.L = slider.doubleValue
      setNeedsDisplay(frame)
    case sliderMu:
      vectorField.mu = slider.doubleValue
      setNeedsDisplay(frame)
    case sliderG:
      vectorField.G = slider.doubleValue
      setNeedsDisplay(frame)
    case _:
      break
    }
  }
}

private extension PendulumSimulationView {
  func drawMousePosition(_ dirtyRect: NSRect) {
    var bezierPath = NSBezierPath()
    bezierPath.move(to: mouseOverPoint)
    bezierPath.line(to: .init(x: mouseOverPoint.x, y: frame.midY))
    bezierPath.move(to: mouseOverPoint)
    bezierPath.line(to: .init(x: frame.midX, y: mouseOverPoint.y))
    let dashes: [CGFloat] = [0, 4]
    bezierPath.setLineDash(dashes, count: dashes.count, phase: 2)
    bezierPath.lineWidth = 4
    NSColor.black.setStroke()
    bezierPath.stroke()
    
    bezierPath = NSBezierPath(ovalIn: .init(
      origin: .init(x: mouseOverPoint.x - 5, y: mouseOverPoint.y - 5),
      size: .init(width: 10, height: 10)))
    NSColor.purple.setFill()
    bezierPath.fill()
    
    let endPoint: CGPoint
    switch vectorField.vectorField {
    case .direction?, nil:
      let (theta2, dtheta2) = Pendulum.simulate(G: vectorField.G, L: vectorField.L, theta: theta, dtheta: dtheta, μ: vectorField.mu, time: 0.05, n: 10)
      endPoint = vectorField.convertTo(NSPoint(x: theta2, y: dtheta2))
    case .acceleration?:
      endPoint = vectorField.convertTo(NSPoint(x: dtheta, y: acceleration))
    }

    drawArrow(
      mouseOverPoint,
      endPoint,
      .red
    )
    
    let sign = mouseOverPoint.y < endPoint.y ? -1.0 : 1
    pendulum.arrowLength = Vector(Double(mouseOverPoint.x - endPoint.x), Double(mouseOverPoint.y - endPoint.y)).magnitude * sign
  }
  
  @objc func didTapSimulateButton() {
    if let link = displayLink {
      link.cancel()
      self.displayLink = nil
      pendulumPath = nil
      needsDisplay = true
      angleView.reset()
      return
    }
    
    let time = 10.0 // [s]
    var currentTime = 0.0
    let h = 0.0175
    let path = NSBezierPath()
    path.lineWidth = 2
    pendulumPath = path
    
    let initialAngle = theta

    displayLink = DisplayLink()
    displayLink?.callback = {
      self.angleView.harmonicAngle = Pendulum.harmonic(G: self.vectorField.G, L: self.vectorField.L, theta: initialAngle, time: currentTime)
      
      path.move(to: self.vectorField.convertTo(.init(x: self.theta, y: self.dtheta)))
      (self.theta, self.dtheta) = Pendulum.simulate(G: self.vectorField.G, L: self.vectorField.L, theta: self.theta, dtheta: self.dtheta, μ: self.vectorField.mu, time: h, n: 10)
      self.mouseOverPoint = self.vectorField.convertTo(.init(x: self.theta, y: self.dtheta))
      path.line(to: self.mouseOverPoint)
      
      self.needsDisplay = true
      
      if true || currentTime < time {
        currentTime += h
      } else {
        self.displayLink?.cancel()
        print("done")
      }
    }
    displayLink?.start()
  }
  
  @objc func didTapToggleButton() {
    angleView.isHidden.toggle()
    vectorField.isHidden.toggle()
    angleView.reset()
  }
  
  @objc func didTapRadioButton(_ button: NSButton) {
    switch button {
    case accelerationVectorFieldButton:
      vectorField.vectorField = .acceleration
    case directionVectorFieldButton:
      vectorField.vectorField = .direction
    case _:
      vectorField.vectorField = nil
    }
    needsDisplay = true
  }
}

func drawLine(
  _ from: CGPoint,
  _ to: CGPoint,
  _ color: NSColor,
  _ width: CGFloat = 2)
{
  let bezierPath = NSBezierPath()
  bezierPath.move(to: from)
  bezierPath.line(to: to)
  color.setStroke()
  bezierPath.lineWidth = width
  bezierPath.stroke()
}

func drawArrow(
  _ from: CGPoint,
  _ to: CGPoint,
  _ color: NSColor,
  _ width: CGFloat = 2,
  _ pointerLength: CGFloat = 7)
{
  drawLine(from, to, color, width)
  let path = NSBezierPath()
  path.addArrow(start: from, end: to, pointerLineLength: pointerLength, arrowAngle: .pi / 5)
  color.setStroke()
  path.lineWidth = width
  path.stroke()
}

extension NSBezierPath {
  func addArrow(start: CGPoint, end: CGPoint, pointerLineLength: CGFloat, arrowAngle: CGFloat) {
    if start == end { return }
    
    let startEndAngle = atan((end.y - start.y) / (end.x - start.x)) + ((end.x - start.x) < 0 ? CGFloat(Double.pi) : 0)
    let arrowLine1 = CGPoint(x: end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle + arrowAngle), y: end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle + arrowAngle))
    let arrowLine2 = CGPoint(x: end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle - arrowAngle), y: end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle - arrowAngle))
    
    move(to: end)
    line(to: arrowLine1)
    move(to: end)
    line(to: arrowLine2)
  }
}

extension NSPoint {
  var normalized: NSPoint {
    let magnitude = sqrt(x * x + y * y)
    return .init(x: x / magnitude, y: y / magnitude)
  }
}

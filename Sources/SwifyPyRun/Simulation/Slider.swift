//
//  Slider.swift
//  SwifyPyRun
//
//  Created by Toni Kocjan on 09/05/2020.
//

import AppKit

class Slider: NSSlider {
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    let text = String(format: "%.2f", doubleValue) as NSString
    let range = maxValue - minValue
    let percentage = CGFloat(doubleValue / range)
    text.draw(
      at: .init(x: frame.width * percentage, y: 10),
      withAttributes: nil
    )
  }
}

import Foundation
import SwifyPy
import AppKit

class Window: NSWindow {
  override var acceptsFirstResponder: Bool { true }
}

class View: NSView {
  var backgroundColor: NSColor? {
    get { layer.flatMap { $0.backgroundColor }.flatMap { NSColor(cgColor: $0) } }
    set { layer?.backgroundColor = newValue?.cgColor }
  }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    backgroundColor = .white
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

let application = NSApplication.shared
let screen = NSScreen.screens.first!
let window = Window(
  contentRect: screen.frame,
  styleMask: [.closable, .titled, .resizable],
  backing: .buffered,
  defer: false
)

let contentView = View()
window.contentView = contentView
contentView.backgroundColor = .black

let simulation = PendulumSimulationView(
  xAxis: stride(from: -4 * .pi, through: 4 * .pi, by: .pi / 2).map { $0 },
  yAxis: stride(from: -8, through: 8, by: 1).map { $0 }
)
contentView.addSubview(simulation)
simulation.frame = contentView.frame

window.title = "Pendulum"
window.makeKeyAndOrderFront(nil)
window.makeMain()
window.acceptsMouseMovedEvents = true
window.orderFrontRegardless()
NSApp.run()

//
//  DisplayLink.swift
//  PythonKit
//
//  Created by Toni Kocjan on 16/05/2020.
//

import Foundation
import AppKit

/**
 Analog to the CADisplayLink in iOS.
 */
class DisplayLink {
  private let timer  : CVDisplayLink
  private let source : DispatchSourceUserDataAdd
  
  var callback : Optional<() -> ()> = nil
  
  var isRunning : Bool { CVDisplayLinkIsRunning(timer) }
  
  /**
   Creates a new DisplayLink that gets executed on the given queue
   
   - Parameters:
   - queue: Queue which will receive the callback calls
   */
  init(onQueue queue: DispatchQueue = DispatchQueue.main) {
    // Source
    source = DispatchSource.makeUserDataAddSource(queue: queue)
    
    // Timer
    var timerRef: CVDisplayLink?
    
    // Create timer
    var successLink = CVDisplayLinkCreateWithActiveCGDisplays(&timerRef)
    
    guard let timer = timerRef else { fatalError() }
    
    // Set Output
    successLink = CVDisplayLinkSetOutputCallback(
      timer,
      { (timer: CVDisplayLink, currentTime: UnsafePointer<CVTimeStamp>, outputTime: UnsafePointer<CVTimeStamp>, _: CVOptionFlags, _: UnsafeMutablePointer<CVOptionFlags>, sourceUnsafeRaw : UnsafeMutableRawPointer?) -> CVReturn in
        
        // Un-opaque the source
        if let sourceUnsafeRaw = sourceUnsafeRaw {
          // Update the value of the source, thus, triggering a handle call on the timer
          let sourceUnmanaged = Unmanaged<DispatchSourceUserDataAdd>.fromOpaque(sourceUnsafeRaw)
          sourceUnmanaged.takeUnretainedValue().add(data: 1)
        }
        
        return kCVReturnSuccess
    },
      Unmanaged.passUnretained(source).toOpaque()
    )
    
    guard successLink == kCVReturnSuccess else { fatalError() }
    
    // Connect to display
    successLink = CVDisplayLinkSetCurrentCGDisplay(timer, CGMainDisplayID())
    
    guard successLink == kCVReturnSuccess else { fatalError() }
    
    self.timer = timer
    
    // Timer setup
    source.setEventHandler { [weak self] in
      self?.callback?()
    }
  }
  
  deinit {
    cancel()
  }
  
  /// Starts the timer
  func start() {
    guard !isRunning else { return }
    CVDisplayLinkStart(timer)
    source.resume()
  }
  
  /// Cancels the timer, can be restarted aftewards
  func cancel() {
    guard isRunning else { return }
    CVDisplayLinkStop(timer)
    source.cancel()
  }
}

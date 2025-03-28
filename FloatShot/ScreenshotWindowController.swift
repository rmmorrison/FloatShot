//
//  ScreenshotWindowController.swift
//  FloatShot
//
//  Created by Ryan Morrison on 2025-03-27.
//

import SwiftUI

class ScreenshotWindowController: NSWindowController {
    private var hostingView: NSHostingView<ScreenshotView>?
    
    func showWindow(for image: NSImage) {
        let contentView = ScreenshotView(image: image, onClose: {
            self.window?.close()
        })
        
        let hosting = NSHostingView(rootView: contentView)
        hostingView = hosting
        
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: image.size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false)
        
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.level = .floating
        window.ignoresMouseEvents = false
        window.isMovableByWindowBackground = true
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        
        self.window = window
    }
    
    static func show(image: NSImage) {
        let controller = ScreenshotWindowController()
        controller.showWindow(for: image)
    }
}

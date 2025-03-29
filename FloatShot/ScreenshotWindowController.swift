//
//  ScreenshotWindowController.swift
//  FloatShot
//
//  Created by Ryan Morrison on 2025-03-27.
//

import SwiftUI

class ScreenshotWindowController: NSWindowController {
    private var hostingView: NSHostingView<ScreenshotView>?
    
    func showWindow(screen: NSScreen, for image: NSImage) {
        let contentView = ScreenshotView(image: image, onClose: {
            self.window?.close()
        })
        
        let hosting = NSHostingView(rootView: contentView)
        hostingView = hosting
        
        let mouseLocation = NSEvent.mouseLocation
        let imageSize = image.size
        let offset: CGFloat = 20
        var windowOrigin = CGPoint(
            x: mouseLocation.x - imageSize.width + offset,
            y: mouseLocation.y - offset
        )
        
        // if the screenshot was taken near the corner of a display, be sure to
        // render the frame within the bounds of the display
        let screenFrame = screen.visibleFrame
        windowOrigin.x = max(screenFrame.minX, min(windowOrigin.x, screenFrame.maxX - imageSize.width))
        windowOrigin.y = max(screenFrame.minY, min(windowOrigin.y, screenFrame.maxY - imageSize.height))
        
        let window = NSWindow(
            contentRect: NSRect(origin: windowOrigin, size: image.size),
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
    
    static func show(screen: NSScreen, image: NSImage) {
        let controller = ScreenshotWindowController()
        controller.showWindow(screen: screen, for: image)
    }
}

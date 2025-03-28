//
//  SelectionOverlayWindow.swift
//  FloatShot
//
//  Created by Ryan Morrison on 2025-03-27.
//

import SwiftUI

class SelectionOverlayWindow: NSWindow {
    private var selectionHandler: ((NSImage?) -> Void)? = nil
    private var selectionView: SelectionView!
    
    init() {
        let screenSize = NSScreen.main?.frame ?? .zero
        super.init(
            contentRect: screenSize,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.level = .mainMenu + 1
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.makeKeyAndOrderFront(nil)
        
        selectionView = SelectionView(frame: screenSize)
        self.contentView = selectionView
    }
    
    func beginSelection(completion: @escaping (NSImage?) -> Void) {
        func convertToDisplayCoordinates(_ rect: CGRect) -> CGRect {
            guard let screen = NSScreen.main else { return rect }
            let flippedY = screen.frame.height - rect.origin.y - rect.height
            return CGRect(x: rect.origin.x, y: flippedY, width: rect.width, height: rect.height)
        }

        selectionHandler = completion
        selectionView.onSelectionComplete = { [weak self] rect in
            guard let self = self else { return }
            self.orderOut(nil)
            Task { @MainActor in
                let displayRect = convertToDisplayCoordinates(rect)
                if let cgImage = try? await ScreenshotManager.shared.captureImage(in: displayRect) {
                    // Size the image in points (original selection size) for display
                    let image = NSImage(cgImage: cgImage, size: rect.size)
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
    }
}

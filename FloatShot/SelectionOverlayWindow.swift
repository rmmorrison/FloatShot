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
        selectionHandler = completion
        selectionView.onSelectionComplete = { [weak self] rect in
            guard let self = self else { return }
            self.orderOut(nil)
            Task { @MainActor in
                if let cgImage = try? await ScreenshotManager.shared.captureImage(in: rect) {
                    let image = NSImage(cgImage: cgImage, size: rect.size)
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
    }
}

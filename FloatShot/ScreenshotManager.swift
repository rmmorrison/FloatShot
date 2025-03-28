//
//  ScreenshotManager.swift
//  FloatShot
//
//  Created by Ryan Morrison on 2025-03-27.
//

import SwiftUI
import ScreenCaptureKit

class ScreenshotManager {
    static let shared = ScreenshotManager()
    private var overlayWindow: SelectionOverlayWindow?
    
    func startSelection() {
        guard overlayWindow == nil else { return } // don't allow another selection to take place if one is already in progress
        
        overlayWindow = SelectionOverlayWindow()
        overlayWindow?.beginSelection { image in
            if let image = image {
                ScreenshotWindowController.show(image: image)
            }
            
            self.overlayWindow = nil
        }
    }
    
    func captureImage(in rect: CGRect) async throws -> CGImage? {
        let config = SCStreamConfiguration()
        config.sourceRect = rect
        config.width = Int(rect.width)
        config.height = Int(rect.height)
        
        guard let display = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true).displays.first else {
            return nil
        }
        
        let filter = SCContentFilter(display: display, excludingWindows: [])
        
        return try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
    }
    
    func forcePermissionRequest() async throws {
        let screen = NSScreen.main?.frame ?? .zero
        let dummyRect = CGRect(x: screen.midX - 1, y: screen.midY - 1, width: 1, height: 1)
        _ = try await captureImage(in: dummyRect)
    }
}

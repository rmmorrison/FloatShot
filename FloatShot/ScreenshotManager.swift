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
    private var overlayWindows: [SelectionOverlayWindow] = []

    func startSelection() {
        guard overlayWindows.isEmpty else { return }

        let screens = NSScreen.screens
        var completionCounter = 0
        var selectionMade = false

        overlayWindows = screens.map { screen in
            let window = SelectionOverlayWindow(screen: screen)
            window.beginSelection { image in
                completionCounter += 1
                if let image = image, !selectionMade {
                    selectionMade = true
                    ScreenshotWindowController.show(screen: screen, image: image)
                    self.dismissAllOverlays()
                } else if completionCounter == screens.count {
                    self.dismissAllOverlays()
                }
            }
            return window
        }
    }

    private func dismissAllOverlays() {
        overlayWindows.forEach { $0.orderOut(nil) }
        overlayWindows.removeAll()
    }

    func captureImage(screen: NSScreen, rect: CGRect) async throws -> CGImage? {
        let config = SCStreamConfiguration()
        config.sourceRect = rect
        config.width = Int(rect.width)
        config.height = Int(rect.height)
        
        guard let screenDisplayID = screen.displayID else {
            return nil
        }

        guard let display = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            .displays.first(where: { $0.displayID == screenDisplayID }) else {
            return nil
        }

        let filter = SCContentFilter(display: display, excludingWindows: [])
        return try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
    }

    func forcePermissionRequest() async throws {
        if let screen = NSScreen.main {
            let frame = screen.frame
            let dummyRect = CGRect(x: frame.midX - 1, y: frame.midY - 1, width: 1, height: 1)
            _ = try await captureImage(screen: screen, rect: dummyRect)
        }
    }
}

extension NSScreen {
    var displayID: CGDirectDisplayID? {
        guard let screenNumber = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
            return nil
        }
        return CGDirectDisplayID(screenNumber.uint32Value)
    }
}

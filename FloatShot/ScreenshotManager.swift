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
                    ScreenshotWindowController.show(image: image)
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

    func captureImage(in rect: CGRect) async throws -> CGImage? {
        let config = SCStreamConfiguration()
        config.sourceRect = rect
        config.width = Int(rect.width)
        config.height = Int(rect.height)

        guard let display = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            .displays.first(where: { $0.frame.contains(rect.origin) }) else {
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

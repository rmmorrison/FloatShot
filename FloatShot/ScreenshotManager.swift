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

    func dismissAllOverlays() {
        overlayWindows.forEach { $0.orderOut(nil) }
        overlayWindows.removeAll()
    }

    @MainActor
    func captureImage(screen: NSScreen, rect: CGRect) async throws -> CGImage? {
        let scale = screen.backingScaleFactor

        let config = SCStreamConfiguration()
        config.capturesAudio = false
        config.width = Int(screen.frame.width * scale)
        config.height = Int(screen.frame.height * scale)

        guard let screenDisplayID = screen.displayID else {
            return nil
        }

        guard let display = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            .displays.first(where: { $0.displayID == screenDisplayID }) else {
            return nil
        }

        let filter = SCContentFilter(display: display, excludingWindows: [])

        // capture a full image of the screen.
        // while SCStreamConfiguration allows us to set a 'sourceRect' of the area to capture,
        // it does so producing what appears to be a low resolution or 'blurry' screenshot.
        // we mitigate this by not defining a 'sourceRect' here and instead crop later
        let fullImage: CGImage!
        do {
            fullImage = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
        } catch {
            throw error
        }

        // convert source rectangle which was measured in points to pixels
        // multiply by display scale factor
        let scaledRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.width * scale,
            height: rect.height * scale
        )

        // flip the y-axis - NSScreen.frame.origin and CGImage pixel data start in opposite locations
        let imageHeight = fullImage.height
        let flippedRect = CGRect(
            x: scaledRect.origin.x,
            y: CGFloat(imageHeight) - scaledRect.origin.y - scaledRect.height,
            width: scaledRect.width,
            height: scaledRect.height
        )

        return fullImage.cropping(to: flippedRect)
    }

    func forcePermissionRequest() async throws {
        if let screen = NSScreen.main {
            let frame = screen.frame
            let dummyRect = CGRect(x: frame.midX - 1, y: frame.midY - 1, width: 1, height: 1)
            Task { @MainActor in
                _ = try await captureImage(screen: screen, rect: dummyRect)
            }
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

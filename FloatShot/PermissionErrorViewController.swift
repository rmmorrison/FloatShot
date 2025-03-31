//
//  PermissionErrorViewController.swift
//  FloatShot
//
//  Created by Ryan Morrison on 2025-03-30.
//

import SwiftUI

class PermissionErrorViewController: NSWindowController {
    
    private static var sharedController: PermissionErrorViewController?

    static func show() {
        if let existing = sharedController, let window = existing.window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = PermissionErrorView {
            closeWindow()
        }

        let hostingController = NSHostingController(rootView: contentView)

        let window = NSWindow(
            contentViewController: hostingController
        )
        window.title = "Screenshot Failed to Capture"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()

        let controller = PermissionErrorViewController(window: window)
        sharedController = controller

        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)

        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { _ in
            sharedController = nil
        }
    }

    private static func closeWindow() {
        sharedController?.window?.performClose(nil)
    }
}

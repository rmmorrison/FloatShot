//
//  FloatShotApp.swift
//  FloatShot
//
//  Created by Ryan Morrison on 2025-03-27.
//

import SwiftUI

@main
struct FloatShotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("FloatShot", systemImage: "camera") {
            Button("Take Screenshot") {
                ScreenshotManager.shared.startSelection()
            }.keyboardShortcut("s", modifiers: [.command, .shift]) // Cmd+Shift+S
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        Task {
            _ = try? await ScreenshotManager.shared.forcePermissionRequest()
        }
    }
}

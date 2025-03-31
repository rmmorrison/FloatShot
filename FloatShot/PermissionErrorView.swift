//
//  PermissionErrorView.swift
//  FloatShot
//
//  Created by Ryan Morrison on 2025-03-30.
//

import SwiftUI

struct PermissionErrorView: View {
    let closeAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
                .padding(.top, 20)

            Text("Screen and Audio Recording Permission Required")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("FloatShot failed to capture screenshot. This is likely caused by a missing permission to record your computer's screen. Please click the button below to launch System Settings and ensure that FloatShot has the \"Screen and System Audio Recording\" permission enabled.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer()

            HStack {
                Spacer()
                Button("Open System Settings") {
                    let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenRecording")!
                    NSWorkspace.shared.open(url)
                }
                Button("Close") {
                    NSApp.keyWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.bottom, 20)
            .padding(.trailing, 20)
        }
        .frame(width: 420, height: 325)
        .padding()
    }
}

#Preview {
    PermissionErrorView() {}
}

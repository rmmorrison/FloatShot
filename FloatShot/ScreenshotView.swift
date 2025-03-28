//
//  ScreenshotView.swift
//  FloatShot
//
//  Created by Ryan Morrison on 2025-03-27.
//

import SwiftUI

struct ScreenshotView: View {
    let image: NSImage
    var onClose: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onHover { hovering in
                isHovered = hovering
            }
            .onTapGesture {
                onClose()
            }
            .border(isHovered ? Color.gray : Color.clear, width: 2)
    }
}

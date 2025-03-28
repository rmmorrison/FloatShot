//
//  SelectionView.swift
//  FloatShot
//
//  Created by Ryan Morrison on 2025-03-27.
//

import SwiftUI

class SelectionView: NSView {
    var startPoint: NSPoint = .zero
    var currentPoint: NSPoint = .zero
    var onSelectionComplete: ((CGRect) -> Void)?
    var selectionLayer = CAShapeLayer()
    var instructionBox: NSView!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.addSublayer(selectionLayer)
        selectionLayer.fillColor = NSColor.systemBlue.withAlphaComponent(0.2).cgColor
        selectionLayer.strokeColor = NSColor.systemBlue.cgColor
        selectionLayer.lineWidth = 2
        
        instructionBox = NSView()
        instructionBox.wantsLayer = true
        instructionBox.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        instructionBox.layer?.cornerRadius = 8
        instructionBox.layer?.masksToBounds = true

        let instructionLabel = NSTextField(labelWithString: "Click and drag to select an area")
        instructionLabel.font = .boldSystemFont(ofSize: 18)
        instructionLabel.textColor = .white
        instructionLabel.alignment = .center
        instructionLabel.backgroundColor = .clear
        instructionLabel.isBordered = false
        instructionLabel.isEditable = false
        instructionLabel.isSelectable = false
        instructionLabel.sizeToFit()

        // Add some padding around the text
        let padding: CGFloat = 40
        let backgroundWidth = instructionLabel.frame.width + padding * 2
        let backgroundHeight = instructionLabel.frame.height + padding

        instructionBox.frame = CGRect(
            x: (frame.width - backgroundWidth) / 2,
            y: (frame.height - backgroundHeight) / 2,
            width: backgroundWidth,
            height: backgroundHeight
        )

        // Center the label inside the box
        instructionLabel.frame.origin = CGPoint(
            x: (instructionBox.bounds.width - instructionLabel.frame.width) / 2,
            y: (instructionBox.bounds.height - instructionLabel.frame.height) / 2
        )

        instructionBox.addSubview(instructionLabel)
        addSubview(instructionBox)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with event: NSEvent) {
        startPoint = event.locationInWindow
        instructionBox.removeFromSuperview()
    }
    
    override func mouseDragged(with event: NSEvent) {
        currentPoint = event.locationInWindow
        let rect = NSRect(x: min(startPoint.x, currentPoint.x),
                          y: min(startPoint.y, currentPoint.y),
                          width: abs(startPoint.x - currentPoint.x),
                          height: abs(startPoint.y - currentPoint.y))
        
        let path = CGPath(rect: rect, transform: nil)
        selectionLayer.path = path
    }
    
    override func mouseUp(with event: NSEvent) {
        currentPoint = event.locationInWindow
        let rect = NSRect(x: min(startPoint.x, currentPoint.x),
                          y: min(startPoint.y, currentPoint.y),
                          width: abs(startPoint.x - currentPoint.x),
                          height: abs(startPoint.y - currentPoint.y))
        
        onSelectionComplete?(rect)
    }
}

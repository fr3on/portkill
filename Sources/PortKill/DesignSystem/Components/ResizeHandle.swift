import AppKit
import SwiftUI

struct ResizeHandle: View {
    @Binding var height: Double
    let defaultHeight: Double
    let minHeight: Double
    let maxHeight: Double

    var body: some View {
        ResizeGripRepresentable(
            height: $height,
            defaultHeight: defaultHeight,
            minHeight: minHeight,
            maxHeight: maxHeight
        )
        .frame(height: 12)
        .frame(maxWidth: .infinity)
        .help("Drag down to expand, up to shrink • Double-click to reset")
    }
}

private struct ResizeGripRepresentable: NSViewRepresentable {
    @Binding var height: Double
    let defaultHeight: Double
    let minHeight: Double
    let maxHeight: Double

    func makeNSView(context: Context) -> ResizeGripView {
        let view = ResizeGripView()
        view.configure(
            heightBinding: $height,
            defaultHeight: defaultHeight,
            minHeight: minHeight,
            maxHeight: maxHeight
        )
        return view
    }

    func updateNSView(_ nsView: ResizeGripView, context: Context) {
        nsView.configure(
            heightBinding: $height,
            defaultHeight: defaultHeight,
            minHeight: minHeight,
            maxHeight: maxHeight
        )
    }

    final class ResizeGripView: NSView {
        private var heightBinding: Binding<Double>?
        private var defaultHeight: CGFloat = Theme.Dimensions.defaultPopoverHeight
        private var minHeight: CGFloat = Theme.Dimensions.minPopoverHeight
        private var maxHeight: CGFloat = Theme.Dimensions.maxPopoverHeight

        private var initialDragLocation: NSPoint?
        private var initialWindowFrame: NSRect?
        private let pillLayer = CALayer()

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            setupPill()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            wantsLayer = true
            setupPill()
        }

        func configure(
            heightBinding: Binding<Double>,
            defaultHeight: Double,
            minHeight: Double,
            maxHeight: Double
        ) {
            self.heightBinding = heightBinding
            self.defaultHeight = CGFloat(defaultHeight)
            self.minHeight = CGFloat(minHeight)
            self.maxHeight = CGFloat(maxHeight)
        }

        private func setupPill() {
            pillLayer.cornerRadius = 2
            pillLayer.backgroundColor = NSColor.labelColor.withAlphaComponent(0.18).cgColor
            layer?.addSublayer(pillLayer)
        }

        override func layout() {
            super.layout()
            let pillWidth: CGFloat = 38
            let pillHeight: CGFloat = 4
            pillLayer.frame = CGRect(
                x: (bounds.width - pillWidth) / 2,
                y: (bounds.height - pillHeight) / 2,
                width: pillWidth,
                height: pillHeight
            )
        }

        override func resetCursorRects() {
            addCursorRect(bounds, cursor: .resizeUpDown)
        }

        override func mouseEntered(with event: NSEvent) {
            pillLayer.backgroundColor = NSColor.labelColor.withAlphaComponent(0.38).cgColor
        }

        override func mouseExited(with event: NSEvent) {
            pillLayer.backgroundColor = NSColor.labelColor.withAlphaComponent(0.18).cgColor
        }

        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            trackingAreas.forEach(removeTrackingArea)
            addTrackingArea(NSTrackingArea(
                rect: bounds,
                options: [.mouseEnteredAndExited, .activeAlways],
                owner: self,
                userInfo: nil
            ))
        }

        override func mouseDown(with event: NSEvent) {
            if event.clickCount == 2 {
                resetToDefault()
                return
            }
            initialDragLocation = NSEvent.mouseLocation
            initialWindowFrame = window?.frame
        }

        override func mouseDragged(with event: NSEvent) {
            guard let window, let startLoc = initialDragLocation, let startFrame = initialWindowFrame else { return }
            let currentLoc = NSEvent.mouseLocation
            // In Cocoa screen coordinates, dragging downward decreases y, so deltaY is negative
            let deltaY = currentLoc.y - startLoc.y
            let newHeight = startFrame.height - deltaY
            let clampedHeight = min(max(newHeight, minHeight), maxHeight)

            DispatchQueue.main.async { [weak self] in
                self?.heightBinding?.wrappedValue = Double(clampedHeight)
            }

            // Actively update window frame so it both expands AND shrinks without lag or gaps
            let newFrame = NSRect(
                x: startFrame.origin.x,
                y: startFrame.maxY - clampedHeight,
                width: Theme.Dimensions.popoverWidth,
                height: clampedHeight
            )
            window.setFrame(newFrame, display: true, animate: false)
        }

        override func mouseUp(with event: NSEvent) {
            initialDragLocation = nil
            initialWindowFrame = nil
        }

        private func resetToDefault() {
            guard let window else { return }
            let target = defaultHeight
            DispatchQueue.main.async { [weak self] in
                self?.heightBinding?.wrappedValue = Double(target)
            }
            let current = window.frame
            let newFrame = NSRect(
                x: current.origin.x,
                y: current.maxY - target,
                width: Theme.Dimensions.popoverWidth,
                height: target
            )
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.22
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                window.animator().setFrame(newFrame, display: true)
            }
        }
    }
}

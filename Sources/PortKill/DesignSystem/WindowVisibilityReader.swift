import AppKit
import SwiftUI

/// Manages window transparency, visibility tracking, and initial height restoration.
struct WindowVisibilityReader: NSViewRepresentable {
    let onChange: (Bool) -> Void

    func makeNSView(context: Context) -> TrackingView {
        let view = TrackingView()
        view.onChange = onChange
        return view
    }

    func updateNSView(_ nsView: TrackingView, context: Context) {
        nsView.onChange = onChange
    }

    final class TrackingView: NSView {
        var onChange: ((Bool) -> Void)?
        private var observers: [NSObjectProtocol] = []
        private var lastReported: Bool?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            stopObserving()
            guard let window else {
                report(false)
                return
            }

            // Ensure window background is transparent so frosted glass reaches all edges
            window.isOpaque = false
            window.backgroundColor = .clear

            let saved = UserDefaults.standard.double(forKey: "popoverHeight")
            let targetHeight: CGFloat = (saved >= Theme.Dimensions.minPopoverHeight && saved <= Theme.Dimensions.maxPopoverHeight)
                ? CGFloat(saved)
                : Theme.Dimensions.defaultPopoverHeight

            let current = window.frame
            if abs(current.height - targetHeight) > 1 {
                let newFrame = NSRect(
                    x: current.origin.x,
                    y: current.maxY - targetHeight,
                    width: Theme.Dimensions.popoverWidth,
                    height: targetHeight
                )
                window.setFrame(newFrame, display: true, animate: false)
            }

            let names: [Notification.Name] = [
                NSWindow.didChangeOcclusionStateNotification,
                NSWindow.didBecomeKeyNotification,
                NSWindow.didResignKeyNotification,
                NSWindow.didChangeScreenNotification,
            ]
            observers = names.map { name in
                NotificationCenter.default.addObserver(forName: name, object: window, queue: .main) { [weak self, weak window] _ in
                    MainActor.assumeIsolated {
                        guard let window else { return }
                        self?.report(Self.isOnScreen(window))
                    }
                }
            }
            report(Self.isOnScreen(window))
        }

        private static func isOnScreen(_ window: NSWindow) -> Bool {
            window.isVisible && window.occlusionState.contains(.visible)
        }

        private func report(_ visible: Bool) {
            guard visible != lastReported else { return }
            lastReported = visible
            onChange?(visible)
        }

        private func stopObserving() {
            observers.forEach(NotificationCenter.default.removeObserver)
            observers = []
        }

        override func viewWillMove(toWindow newWindow: NSWindow?) {
            super.viewWillMove(toWindow: newWindow)
            if newWindow == nil { stopObserving() }
        }
    }
}

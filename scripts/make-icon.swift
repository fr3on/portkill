// Usage: swift scripts/make-icon.swift assets/icon.png build/icon-1024.png
// Puts the artwork on the standard macOS icon grid: 824pt rounded square centred in a 1024pt transparent canvas.
import AppKit

let args = CommandLine.arguments
guard args.count == 3, let source = NSImage(contentsOfFile: args[1]) else {
    FileHandle.standardError.write(Data("usage: make-icon.swift <in.png> <out.png>\n".utf8))
    exit(1)
}

let canvas: CGFloat = 1024
let inset: CGFloat = 100
let side = canvas - inset * 2
let rect = CGRect(x: inset, y: inset, width: side, height: side)

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: Int(canvas), pixelsHigh: Int(canvas),
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSBezierPath(roundedRect: rect, xRadius: side * 0.2, yRadius: side * 0.2).addClip()
source.draw(in: rect)
NSGraphicsContext.restoreGraphicsState()

try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))

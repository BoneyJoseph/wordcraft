// Original icon for the modified community build of WordCraft.
// Drawn with AppKit at packaging time; independent of the upstream project's artwork.
// SPDX-License-Identifier: MIT OR Apache-2.0
import AppKit
import Foundation

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: swift custom-icon.swift <output-1024px-png>\n", stderr)
    exit(2)
}

let destination = CommandLine.arguments[1]
let size = 1024
guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
    fputs("Could not allocate the icon canvas.\n", stderr)
    exit(1)
}

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: r / 255, green: g / 255, blue: b / 255, alpha: alpha)
}
func point(_ x: CGFloat, _ y: CGFloat) -> NSPoint { NSPoint(x: x, y: y) }
func polygon(_ vertices: [NSPoint]) -> NSBezierPath {
    let path = NSBezierPath()
    guard let first = vertices.first else { return path }
    path.move(to: first)
    for p in vertices.dropFirst() { path.line(to: p) }
    path.close()
    return path
}
func linear(_ start: NSColor, _ end: NSColor, in path: NSBezierPath, angle: CGFloat) {
    NSGradient(starting: start, ending: end)?.draw(in: path, angle: angle)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context
context.cgContext.clear(CGRect(x: 0, y: 0, width: size, height: size))
context.imageInterpolation = .high

// An original rounded cobalt/violet tile, distinct from the upstream lion icon.
let tile = NSBezierPath(roundedRect: NSRect(x: 48, y: 49, width: 928, height: 928),
                        xRadius: 214, yRadius: 214)
NSGraphicsContext.saveGraphicsState()
let tileShadow = NSShadow()
tileShadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
tileShadow.shadowBlurRadius = 27
tileShadow.shadowOffset = NSSize(width: 0, height: -17)
tileShadow.set()
rgb(27, 75, 181).setFill()
tile.fill()
NSGraphicsContext.restoreGraphicsState()
linear(rgb(10, 109, 233), rgb(80, 29, 185), in: tile, angle: -38)

NSGraphicsContext.saveGraphicsState()
tile.addClip()
// A pair of translucent diagonal shapes give the tile a layered, sculpted appearance.
let upper = polygon([point(30, 882), point(450, 1010), point(800, 1010), point(100, 512)])
rgb(123, 198, 255, 0.17).setFill()
upper.fill()
let lower = polygon([point(470, 45), point(1015, 530), point(1015, 18), point(470, 18)])
rgb(153, 40, 234, 0.70).setFill()
lower.fill()
let leftAccent = polygon([point(37, 250), point(250, 460), point(350, 405), point(38, 115)])
rgb(6, 39, 146, 0.28).setFill()
leftAccent.fill()
NSGraphicsContext.restoreGraphicsState()

// A document sheet with a real folded upper-right corner.
let page = NSBezierPath()
page.move(to: point(316, 204))
page.line(to: point(705, 204))
page.curve(to: point(745, 246), controlPoint1: point(730, 204), controlPoint2: point(745, 220))
page.line(to: point(745, 710))
page.line(to: point(635, 823))
page.line(to: point(316, 823))
page.curve(to: point(275, 780), controlPoint1: point(290, 823), controlPoint2: point(275, 805))
page.line(to: point(275, 245))
page.curve(to: point(316, 204), controlPoint1: point(275, 220), controlPoint2: point(290, 204))
page.close()
NSGraphicsContext.saveGraphicsState()
let documentShadow = NSShadow()
documentShadow.shadowColor = rgb(10, 22, 72, 0.42)
documentShadow.shadowBlurRadius = 35
documentShadow.shadowOffset = NSSize(width: 8, height: -20)
documentShadow.set()
NSColor.white.setFill()
page.fill()
NSGraphicsContext.restoreGraphicsState()
linear(rgb(255, 255, 255), rgb(216, 225, 247), in: page, angle: 100)

// Raised fold with a subtle seam.
let fold = polygon([point(635, 823), point(635, 751), point(653, 716),
                    point(745, 710)])
linear(rgb(252, 253, 255), rgb(178, 196, 238), in: fold, angle: 130)
rgb(129, 152, 214, 0.5).setStroke()
fold.lineWidth = 3
fold.stroke()

// High-contrast PDF monogram remains readable at Dock and Finder icon sizes.
let text = "W" as NSString
let attributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 188, weight: .heavy),
    .foregroundColor: rgb(21, 32, 61)
]
let textSize = text.size(withAttributes: attributes)
text.draw(at: point(512 - textSize.width / 2, 420), withAttributes: attributes)

let line1 = NSBezierPath(roundedRect: NSRect(x: 360, y: 372, width: 300, height: 17), xRadius: 8, yRadius: 8)
let line2 = NSBezierPath(roundedRect: NSRect(x: 360, y: 333, width: 225, height: 16), xRadius: 8, yRadius: 8)
rgb(145, 157, 196, 0.62).setFill()
line1.fill()
line2.fill()

// Final violet ribbon balances the shape and visually identifies this edition.
NSGraphicsContext.saveGraphicsState()
tile.addClip()
let ribbon = polygon([point(574, 48), point(976, 455), point(976, 220),
                      point(806, 48)])
linear(rgb(130, 41, 238), rgb(78, 22, 188), in: ribbon, angle: -44)
NSGraphicsContext.restoreGraphicsState()

context.flushGraphics()
NSGraphicsContext.restoreGraphicsState()
guard let data = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Could not encode the icon PNG.\n", stderr)
    exit(1)
}
do {
    try data.write(to: URL(fileURLWithPath: destination), options: .atomic)
} catch {
    fputs("Could not save icon: \(error)\n", stderr)
    exit(1)
}

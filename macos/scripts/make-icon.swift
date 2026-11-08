// Regenerates ZeusApp/Assets.xcassets/AppIcon.appiconset: `swift scripts/make-icon.swift`
import AppKit

let dir = "ZeusApp/Assets.xcassets/AppIcon.appiconset"
try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)

func render(_ px: Int) -> Data {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    // Apple's icon grid: the artwork fills ~80% of the canvas, with a continuous-corner squircle.
    let inset = s * 0.1, body = NSRect(x: inset, y: inset, width: s - 2 * inset, height: s - 2 * inset)
    let path = NSBezierPath(roundedRect: body, xRadius: body.width * 0.225, yRadius: body.width * 0.225)
    NSGradient(colors: [NSColor(srgbRed: 0.10, green: 0.16, blue: 0.42, alpha: 1), NSColor(srgbRed: 0.36, green: 0.22, blue: 0.78, alpha: 1)])!
        .draw(in: path, angle: -60)
    let cfg = NSImage.SymbolConfiguration(pointSize: body.width * 0.5, weight: .bold)
        .applying(.init(paletteColors: [.white]))
    if let bolt = NSImage(systemSymbolName: "bolt.fill", accessibilityDescription: nil)?.withSymbolConfiguration(cfg) {
        let sz = bolt.size
        bolt.draw(in: NSRect(x: body.midX - sz.width / 2, y: body.midY - sz.height / 2, width: sz.width, height: sz.height))
    }
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

var images: [[String: String]] = []
for base in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let name = "icon_\(base)x\(base)\(scale == 2 ? "@2x" : "").png"
        try render(base * scale).write(to: URL(fileURLWithPath: "\(dir)/\(name)"))
        images.append(["size": "\(base)x\(base)", "idiom": "mac", "filename": name, "scale": "\(scale)x"])
    }
}
let contents: [String: Any] = ["images": images, "info": ["version": 1, "author": "xcode"]]
try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
    .write(to: URL(fileURLWithPath: "\(dir)/Contents.json"))
try #"{"info":{"version":1,"author":"xcode"}}"#.write(toFile: "ZeusApp/Assets.xcassets/Contents.json", atomically: true, encoding: .utf8)

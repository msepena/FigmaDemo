import AppKit
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

enum RenderMode {
    case light
    case dark
    case tinted // monochrome white-on-transparent for iOS 18+ home-screen tinting
}

enum RenderVariant {
    case icon       // full-bleed bg + card + grid + colored marks
    case launchLogo // transparent canvas — card + grid + marks only
}

enum IconRenderer {
    static func render(mode: RenderMode, variant: RenderVariant, size: CGFloat) -> CGImage {
        let pixelSize = Int(size)
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let ctx = CGContext(
            data: nil,
            width: pixelSize,
            height: pixelSize,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            fatalError("AssetGen: failed to allocate CGContext at \(pixelSize)x\(pixelSize)")
        }

        ctx.setShouldAntialias(true)
        ctx.setAllowsAntialiasing(true)
        ctx.interpolationQuality = .high

        // Background fill (full bleed) — only for non-tinted icon variants.
        switch (variant, mode) {
        case (.icon, .light):
            ctx.setFillColor(Palette.bgLight.cgColor)
            ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
        case (.icon, .dark):
            ctx.setFillColor(Palette.bgDark.cgColor)
            ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
        case (.icon, .tinted), (.launchLogo, _):
            break // leave transparent
        }

        // The tinted icon skips the card entirely so iOS's home-screen mask + tint
        // operate cleanly on a single foreground layer.
        let drawCard: Bool
        switch (variant, mode) {
        case (.icon, .tinted): drawCard = false
        default:               drawCard = true
        }

        // Card rect — slightly inset from canvas for icon, flush for launch.
        let cardInsetRatio: CGFloat = (variant == .icon) ? 0.08 : 0.0
        let cardInset = size * cardInsetRatio
        let cardRect = CGRect(
            x: cardInset,
            y: cardInset,
            width: size - cardInset * 2,
            height: size - cardInset * 2
        )
        let cardRadius = size * 0.18

        if drawCard {
            ctx.saveGState()
            // Subtle drop shadow under the card (CG y-up: negative y = below).
            ctx.setShadow(
                offset: CGSize(width: 0, height: -size * 0.012),
                blur: size * 0.025,
                color: NSColor.black.withAlphaComponent(0.10).cgColor
            )
            let cardFill: NSColor = (mode == .dark) ? Palette.cardDark : Palette.cardLight
            ctx.setFillColor(cardFill.cgColor)
            let path = CGPath(
                roundedRect: cardRect,
                cornerWidth: cardRadius,
                cornerHeight: cardRadius,
                transform: nil
            )
            ctx.addPath(path)
            ctx.fillPath()
            ctx.restoreGState()
        }

        // Grid box — inset from the card (or from the full canvas, for tinted).
        let gridBox: CGRect = {
            if drawCard {
                let inset = size * 0.10
                return cardRect.insetBy(dx: inset, dy: inset)
            } else {
                let inset = size * 0.14
                return CGRect(x: 0, y: 0, width: size, height: size).insetBy(dx: inset, dy: inset)
            }
        }()
        let cellSize = gridBox.width / 3.0

        // Grid lines.
        let gridColor: NSColor
        switch mode {
        case .tinted: gridColor = .white
        case .dark:   gridColor = Palette.gridLineDark
        case .light:  gridColor = Palette.gridLineLight
        }
        let lineWidth = size * 0.014
        ctx.setStrokeColor(gridColor.cgColor)
        ctx.setLineWidth(lineWidth)
        ctx.setLineCap(.round)

        for i in 1...2 {
            let xc = gridBox.minX + cellSize * CGFloat(i)
            ctx.move(to: CGPoint(x: xc, y: gridBox.minY + lineWidth))
            ctx.addLine(to: CGPoint(x: xc, y: gridBox.maxY - lineWidth))
        }
        for i in 1...2 {
            let yc = gridBox.minY + cellSize * CGFloat(i)
            ctx.move(to: CGPoint(x: gridBox.minX + lineWidth, y: yc))
            ctx.addLine(to: CGPoint(x: gridBox.maxX - lineWidth, y: yc))
        }
        ctx.strokePath()

        // Mark glyphs — X top-left cell, O center cell.
        // CG uses y-up: visual "top row" sits at y = gridBox.minY + cellSize * 2 … 3.
        // The launch logo is intentionally rendered without marks so the SwiftUI
        // post-launch splash can animate them in over an otherwise-identical card.
        if variant == .icon {
            let glyphInkWidth = cellSize * 0.62
            let xColor: NSColor = (mode == .tinted) ? .white : Palette.playerXBlue
            let oColor: NSColor = (mode == .tinted) ? .white : Palette.playerOOrange
            let topLeftCenter = CGPoint(
                x: gridBox.minX + cellSize * 0.5,
                y: gridBox.minY + cellSize * 2.5
            )
            let centerCenter = CGPoint(
                x: gridBox.minX + cellSize * 1.5,
                y: gridBox.minY + cellSize * 1.5
            )
            drawGlyph("X", center: topLeftCenter, targetInkWidth: glyphInkWidth, color: xColor, in: ctx)
            drawGlyph("O", center: centerCenter, targetInkWidth: glyphInkWidth, color: oColor, in: ctx)
        }

        guard let cgImage = ctx.makeImage() else {
            fatalError("AssetGen: CGContext.makeImage() returned nil")
        }
        return cgImage
    }

    /// Draws `glyph` so its actual ink bounds are `targetInkWidth` wide and centered
    /// at `center`. SF Pro Rounded has a lot of em-box whitespace, so picking font
    /// size by point-size leaves the glyph looking tiny; we measure-then-scale instead.
    ///
    /// `CTLineGetImageBounds` reads the context's current `textPosition` as the line
    /// origin, so we must reset it to zero before measuring — otherwise a prior
    /// `CTLineDraw` shifts the next glyph far off-canvas.
    private static func drawGlyph(
        _ glyph: String,
        center: CGPoint,
        targetInkWidth: CGFloat,
        color: NSColor,
        in ctx: CGContext
    ) {
        ctx.saveGState()
        defer { ctx.restoreGState() }
        ctx.textPosition = .zero

        let probeSize: CGFloat = 200
        let probeFont = roundedBold(size: probeSize)
        let probeAttrs: [NSAttributedString.Key: Any] = [.font: probeFont]
        let probeLine = CTLineCreateWithAttributedString(
            NSAttributedString(string: glyph, attributes: probeAttrs)
        )
        let probeBounds = CTLineGetImageBounds(probeLine, ctx)
        let finalSize = probeSize * (targetInkWidth / probeBounds.width)

        let font = roundedBold(size: finalSize)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        let line = CTLineCreateWithAttributedString(
            NSAttributedString(string: glyph, attributes: attrs)
        )
        ctx.textPosition = .zero
        let inkBounds = CTLineGetImageBounds(line, ctx)
        ctx.textPosition = CGPoint(
            x: center.x - inkBounds.midX,
            y: center.y - inkBounds.midY
        )
        CTLineDraw(line, ctx)
    }

    private static func roundedBold(size: CGFloat) -> NSFont {
        let base = NSFont.systemFont(ofSize: size, weight: .bold)
        let descriptor = base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor
        return NSFont(descriptor: descriptor, size: size) ?? base
    }
}

enum PNG {
    static func write(_ image: CGImage, to url: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            throw NSError(
                domain: "AssetGen",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Couldn't create PNG destination at \(url.path)"]
            )
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw NSError(
                domain: "AssetGen",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "PNG finalize failed for \(url.path)"]
            )
        }
    }
}

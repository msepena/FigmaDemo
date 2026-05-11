import SwiftUI
import DesignSystem

/// The X / O glyph used inside board cells and the brand splash. Single source
/// of truth so the launch image, in-app board, and animated splash all render
/// the marks identically.
public struct MarkGlyph: View {
    public enum Side: Sendable, Hashable {
        case x
        case o
    }

    private let side: Side
    private let font: Font
    private let xColor: Color?

    /// - Parameters:
    ///   - side: which mark to render.
    ///   - font: typographic ramp slot (defaults to `DSFont.markGlyph` for the board).
    ///   - xColorOverride: pass a non-nil colour to override the `\.dsAccentColor`
    ///     environment for the X mark — used by the splash so it doesn't depend on
    ///     the user's accent preference.
    public init(
        side: Side,
        font: Font = DSFont.markGlyph,
        xColorOverride: Color? = nil
    ) {
        self.side = side
        self.font = font
        self.xColor = xColorOverride
    }

    @Environment(\.dsAccentColor) private var accent

    public var body: some View {
        Text(side == .x ? "X" : "O")
            .font(font)
            .foregroundStyle(side == .x ? (xColor ?? accent) : DSColor.playerOOrange)
    }
}

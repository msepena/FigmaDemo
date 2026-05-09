import SwiftUI

/// Typed font ramp matching the Figma design. Uses SwiftUI system fonts —
/// `.rounded` design where the comp specifies SF Pro Rounded (title and X/O markers),
/// `.default` design elsewhere. No bundled font resources.
public enum DSFont {
    /// 12pt medium uppercase — small section labels (e.g. "PLAYER X")
    public static var eyebrowSmall: Font {
        .system(size: 12, weight: .medium, design: .default)
    }

    /// 13pt medium — eyebrow above the screen title (e.g. "ROUND 9")
    public static var eyebrow: Font {
        .system(size: 13, weight: .medium, design: .default)
    }

    /// 15pt semibold — pill / inline emphasis ("Your turn")
    public static var bodyEmphasized: Font {
        .system(size: 15, weight: .semibold, design: .default)
    }

    /// 17pt regular — buttons / row text
    public static var bodyRegular: Font {
        .system(size: 17, weight: .regular, design: .default)
    }

    /// 17pt semibold — primary button label
    public static var buttonLabel: Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    /// 28pt bold rounded — large screen title ("Tic Tac Toe")
    public static var titleLarge: Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }

    /// 28pt bold rounded — scoreboard score numbers
    public static var scoreNumber: Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }

    /// 14pt bold rounded — tiny X/O glyph in turn indicator badge
    public static var turnBadgeGlyph: Font {
        .system(size: 14, weight: .bold, design: .rounded)
    }

    /// 64pt bold rounded — X / O markers inside board cells
    public static var markGlyph: Font {
        .system(size: 64, weight: .bold, design: .rounded)
    }
}

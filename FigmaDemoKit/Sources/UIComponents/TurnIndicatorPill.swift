import SwiftUI
import DesignSystem

public struct TurnIndicatorPill: View {
    private let letter: String
    private let tint: Color
    private let text: String

    public init(letter: String, tint: Color, text: String) {
        self.letter = letter
        self.tint = tint
        self.text = text
    }

    public var body: some View {
        HStack(spacing: DSSpacing.sm) {
            ZStack {
                Circle()
                    .fill(tint)
                    .frame(width: 22, height: 22)
                Text(letter)
                    .font(DSFont.turnBadgeGlyph)
                    .foregroundStyle(.white)
            }

            Text(text)
                .font(DSFont.bodyEmphasized)
                .foregroundStyle(tint)
        }
        .padding(.vertical, DSSpacing.sm)
        .padding(.leading, 14)
        .padding(.trailing, DSSpacing.lg)
        .background(
            Capsule().fill(tint.opacity(0.12))
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        TurnIndicatorPill(letter: "X", tint: DSColor.playerXBlue, text: "Your turn")
        TurnIndicatorPill(letter: "O", tint: DSColor.playerOOrange, text: "Your turn")
    }
    .padding(20)
    .background(DSColor.bg)
}

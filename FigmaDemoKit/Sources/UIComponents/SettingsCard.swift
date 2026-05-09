import SwiftUI
import DesignSystem

/// Rounded white card used to group settings rows. Lighter shadow and smaller
/// corner radius than ``BoardCardContainer`` — the two are intentionally
/// distinct atoms so each can evolve independently.
public struct SettingsCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: DSRadius.card16)
                .fill(DSColor.cardBackground)
        )
        .dsShadow(.card)
    }
}

/// Hairline divider sized to sit between rows inside a ``SettingsCard``.
/// Inset 16pt from the leading edge to match the Figma comp.
public struct SettingsCardDivider: View {
    public init() {}

    public var body: some View {
        Rectangle()
            .fill(DSColor.gridLine)
            .frame(height: 0.5)
            .padding(.leading, DSSpacing.lg)
    }
}

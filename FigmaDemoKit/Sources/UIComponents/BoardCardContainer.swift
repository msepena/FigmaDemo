import SwiftUI
import DesignSystem

public struct BoardCardContainer<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.card24)
                    .fill(DSColor.cardBackground)
            )
            .dsShadow(.board)
    }
}

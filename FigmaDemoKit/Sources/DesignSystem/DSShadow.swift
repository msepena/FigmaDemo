import SwiftUI

public struct DSShadow: Sendable {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }

    /// Subtle shadow under cards (scoreboard etc.)
    public static let card = DSShadow(
        color: .black.opacity(0.04), radius: 8, x: 0, y: 2
    )

    /// Heavier shadow under the board container
    public static let board = DSShadow(
        color: .black.opacity(0.06), radius: 18, x: 0, y: 6
    )

    /// Settings gear button — very subtle
    public static let iconButton = DSShadow(
        color: .black.opacity(0.06), radius: 6, x: 0, y: 2
    )
}

extension View {
    /// Apply a `DSShadow` token.
    public func dsShadow(_ shadow: DSShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

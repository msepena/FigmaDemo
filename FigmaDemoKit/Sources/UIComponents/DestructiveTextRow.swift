import SwiftUI
import DesignSystem

/// Single-row card content with centered, destructive-tinted text. Used for
/// "Reset Stats" — full-width tap target rendered inside a ``SettingsCard``.
public struct DestructiveTextRow: View {
    private let title: String
    private let action: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSFont.bodyRegular)
                .foregroundStyle(DSColor.destructive)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 45)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

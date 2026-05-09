import SwiftUI
import DesignSystem

/// Horizontal row inside a ``SettingsCard``: leading title + trailing slot.
/// The trailing closure is `@ViewBuilder`, so callers can drop in a value
/// label, a `Toggle`, or any other small control.
public struct SettingsRow<Trailing: View>: View {
    private let title: String
    private let trailing: Trailing

    public init(title: String, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: DSSpacing.md) {
            Text(title)
                .font(DSFont.bodyRegular)
                .foregroundStyle(DSColor.label)
            Spacer(minLength: 0)
            trailing
        }
        .padding(.horizontal, DSSpacing.lg)
        .frame(minHeight: 44)
    }
}

extension SettingsRow where Trailing == EmptyView {
    /// Convenience for rows with no trailing slot.
    public init(title: String) {
        self.init(title: title) { EmptyView() }
    }
}

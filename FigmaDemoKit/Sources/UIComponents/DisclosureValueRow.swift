import SwiftUI
import DesignSystem

/// Tappable row showing `title — value ›`, used for settings that drill into
/// a sub-screen. The action is provided by the caller; v1 of the Settings
/// screen passes a no-op for "Marker Style — Rounded ›".
public struct DisclosureValueRow: View {
    private let title: String
    private let value: String
    private let action: () -> Void

    public init(title: String, value: String, action: @escaping () -> Void) {
        self.title = title
        self.value = value
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.sm) {
                Text(title)
                    .font(DSFont.bodyRegular)
                    .foregroundStyle(DSColor.label)
                Spacer(minLength: 0)
                Text(value)
                    .font(DSFont.bodyRegular)
                    .foregroundStyle(DSColor.secondary)
                Text("›")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(DSColor.secondary)
            }
            .padding(.horizontal, DSSpacing.lg)
            .frame(minHeight: 45)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

import SwiftUI
import DesignSystem

/// Settings row whose trailing slot is an iOS-style `Toggle`.
public struct ToggleRow: View {
    private let title: String
    @Binding private var isOn: Bool

    public init(title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(DSFont.bodyRegular)
                .foregroundStyle(DSColor.label)
        }
        .padding(.horizontal, DSSpacing.lg)
        .frame(minHeight: 53)
    }
}

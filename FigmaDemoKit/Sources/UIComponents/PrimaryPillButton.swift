import SwiftUI
import DesignSystem

public struct PrimaryPillButton: View {
    private let title: String
    private let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSFont.buttonLabel)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.lg)
                .background(
                    Capsule().fill(DSColor.label)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PrimaryPillButton("New Game") {}
        .padding(20)
        .background(DSColor.bg)
}

import SwiftUI
import DesignSystem

public struct TextLinkButton: View {
    private let title: String
    private let isEnabled: Bool
    private let action: () -> Void

    public init(_ title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSFont.bodyEmphasized)
                .foregroundStyle(isEnabled ? DSColor.playerXBlue : DSColor.secondary)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack {
        TextLinkButton("Undo last move") {}
        TextLinkButton("Undo last move", isEnabled: false) {}
    }
    .padding()
}

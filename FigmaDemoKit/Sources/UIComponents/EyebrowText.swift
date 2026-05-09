import SwiftUI
import DesignSystem

public struct EyebrowText: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(DSFont.eyebrow)
            .tracking(1.5)
            .foregroundStyle(DSColor.secondary)
            .textCase(.uppercase)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        EyebrowText("Round 9")
        EyebrowText("Game")
    }
    .padding()
}

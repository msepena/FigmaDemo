import SwiftUI
import DesignSystem

public struct CircularIconButton: View {
    private let systemImage: String
    private let action: () -> Void

    public init(systemImage: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(DSColor.label)
                .frame(width: 40, height: 40)
                .background(
                    Circle().fill(DSColor.cardBackground)
                )
                .dsShadow(.iconButton)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CircularIconButton(systemImage: "gearshape.fill") {}
        .padding()
        .background(DSColor.bg)
}

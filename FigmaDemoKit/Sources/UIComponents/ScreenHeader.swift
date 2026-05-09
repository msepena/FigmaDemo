import SwiftUI
import DesignSystem

public struct ScreenHeader<Trailing: View>: View {
    private let eyebrow: String?
    private let title: String
    private let trailing: Trailing

    public init(
        eyebrow: String? = nil,
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(alignment: .center, spacing: DSSpacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                if let eyebrow {
                    EyebrowText(eyebrow)
                }
                Text(title)
                    .font(DSFont.titleLarge)
                    .foregroundStyle(DSColor.label)
            }
            Spacer(minLength: 0)
            trailing
        }
    }
}

extension ScreenHeader where Trailing == EmptyView {
    public init(eyebrow: String? = nil, title: String) {
        self.init(eyebrow: eyebrow, title: title, trailing: { EmptyView() })
    }
}

#Preview {
    ScreenHeader(eyebrow: "Round 9", title: "Tic Tac Toe") {
        CircularIconButton(systemImage: "gearshape.fill") {}
    }
    .padding(20)
    .background(DSColor.bg)
}

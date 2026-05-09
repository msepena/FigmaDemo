import SwiftUI
import DesignSystem

/// Horizontal row of circular color swatches with a selection ring around the
/// active one. Generic over the value type so it can drive any preference enum
/// — the Settings screen feeds it a mapping from `AccentColor` cases to
/// SwiftUI `Color`.
public struct AccentSwatchPicker<Value: Hashable>: View {
    @Binding private var selection: Value
    private let options: [(value: Value, color: Color)]

    public init(selection: Binding<Value>, options: [(value: Value, color: Color)]) {
        self._selection = selection
        self.options = options
    }

    public var body: some View {
        HStack(spacing: 14) {
            ForEach(options.indices, id: \.self) { i in
                let option = options[i]
                Button {
                    selection = option.value
                } label: {
                    swatch(color: option.color, isSelected: option.value == selection)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func swatch(color: Color, isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 28, height: 28)
            if isSelected {
                Circle()
                    .stroke(color, lineWidth: 2)
                    .frame(width: 34, height: 34)
            }
        }
        .frame(width: 34, height: 34)
    }
}

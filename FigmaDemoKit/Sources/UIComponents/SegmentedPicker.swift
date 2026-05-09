import SwiftUI

/// Thin wrapper around `Picker.pickerStyle(.segmented)` that accepts a
/// `[(Value, String)]` mapping — keeps call sites declarative when the
/// underlying enum doesn't directly produce the display strings we want
/// (e.g. ``FirstMove.x`` → "X").
public struct SegmentedPicker<Value: Hashable>: View {
    @Binding private var selection: Value
    private let options: [(value: Value, label: String)]

    public init(selection: Binding<Value>, options: [(value: Value, label: String)]) {
        self._selection = selection
        self.options = options
    }

    public var body: some View {
        Picker("", selection: $selection) {
            ForEach(options.indices, id: \.self) { i in
                Text(options[i].label).tag(options[i].value)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }
}

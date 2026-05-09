import SwiftUI
import DesignSystem

public struct ScoreColumn: Identifiable, Sendable {
    public let id = UUID()
    public let label: String
    public let value: String
    public let valueColor: Color

    public init(label: String, value: String, valueColor: Color) {
        self.label = label
        self.value = value
        self.valueColor = valueColor
    }
}

public struct ScoreboardCard: View {
    private let columns: [ScoreColumn]

    public init(columns: [ScoreColumn]) {
        self.columns = columns
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(columns.enumerated()), id: \.element.id) { index, column in
                ScoreColumnView(column: column)
                    .frame(maxWidth: .infinity)

                if index < columns.count - 1 {
                    Rectangle()
                        .fill(DSColor.gridLine)
                        .frame(width: 1, height: 32)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.card16)
                .fill(DSColor.cardBackground)
        )
        .dsShadow(.card)
    }
}

private struct ScoreColumnView: View {
    let column: ScoreColumn

    var body: some View {
        VStack(spacing: DSSpacing.xs) {
            Text(column.label)
                .font(DSFont.eyebrowSmall)
                .tracking(2)
                .foregroundStyle(DSColor.secondary)
                .textCase(.uppercase)
            Text(column.value)
                .font(DSFont.scoreNumber)
                .foregroundStyle(column.valueColor)
        }
        .padding(.vertical, DSSpacing.xs)
    }
}

#Preview {
    ScoreboardCard(columns: [
        .init(label: "Player X", value: "5", valueColor: DSColor.playerXBlue),
        .init(label: "Draws",    value: "1", valueColor: DSColor.label),
        .init(label: "Player O", value: "3", valueColor: DSColor.playerOOrange),
    ])
    .padding(20)
    .background(DSColor.bg)
}

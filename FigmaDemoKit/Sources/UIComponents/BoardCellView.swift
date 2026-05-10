import SwiftUI
import DesignSystem

public enum CellVisualState: Sendable, Hashable {
    case empty
    case x
    case o
    case xWinning
    case oWinning

    public var glyph: String? {
        switch self {
        case .empty: return nil
        case .x, .xWinning: return "X"
        case .o, .oWinning: return "O"
        }
    }

    public func glyphColor(accent: Color) -> Color {
        switch self {
        case .empty, .x, .xWinning: return accent
        case .o, .oWinning: return DSColor.playerOOrange
        }
    }

    public func background(accent: Color) -> Color {
        switch self {
        case .empty, .x, .o: return DSColor.emptyCell
        case .xWinning: return accent.opacity(0.12)
        case .oWinning: return DSColor.winHighlightOrange
        }
    }
}

public struct BoardCellView: View {
    @Environment(\.dsAccentColor) private var accent
    private let state: CellVisualState
    private let action: () -> Void

    public init(state: CellVisualState, action: @escaping () -> Void) {
        self.state = state
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: DSRadius.cell)
                    .fill(state.background(accent: accent))
                if let glyph = state.glyph {
                    Text(glyph)
                        .font(DSFont.markGlyph)
                        .foregroundStyle(state.glyphColor(accent: accent))
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .disabled(state.glyph != nil)
    }
}

#Preview {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
        BoardCellView(state: .xWinning) {}
        BoardCellView(state: .empty) {}
        BoardCellView(state: .o) {}
        BoardCellView(state: .empty) {}
        BoardCellView(state: .xWinning) {}
        BoardCellView(state: .empty) {}
        BoardCellView(state: .o) {}
        BoardCellView(state: .empty) {}
        BoardCellView(state: .xWinning) {}
    }
    .padding()
    .background(.white)
}

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

    public var glyphColor: Color {
        switch self {
        case .empty, .x, .xWinning: return DSColor.playerXBlue
        case .o, .oWinning: return DSColor.playerOOrange
        }
    }

    public var background: Color {
        switch self {
        case .empty, .x, .o: return DSColor.emptyCell
        case .xWinning: return DSColor.winHighlightBlue
        case .oWinning: return DSColor.winHighlightOrange
        }
    }
}

public struct BoardCellView: View {
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
                    .fill(state.background)
                if let glyph = state.glyph {
                    Text(glyph)
                        .font(DSFont.markGlyph)
                        .foregroundStyle(state.glyphColor)
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

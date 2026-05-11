import SwiftUI
import DesignSystem

public enum CellVisualState: Sendable, Hashable {
    case empty
    case x
    case o
    case xWinning
    case oWinning

    public var markSide: MarkGlyph.Side? {
        switch self {
        case .empty: return nil
        case .x, .xWinning: return .x
        case .o, .oWinning: return .o
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
                if let side = state.markSide {
                    MarkGlyph(side: side)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .disabled(state.markSide != nil)
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

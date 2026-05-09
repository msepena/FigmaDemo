import SwiftUI
import GameDomain
import DesignSystem
import UIComponents

public struct GameScreen: View {
    @State private var viewModel: GameViewModel
    private let onSettingsTap: () -> Void

    public init(
        viewModel: GameViewModel = GameViewModel(),
        onSettingsTap: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSettingsTap = onSettingsTap
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, DSSpacing.xl)
                        .padding(.vertical, DSSpacing.sm)

                    scoreboard
                        .padding(.horizontal, DSSpacing.xl)
                        .padding(.top, DSSpacing.lg)
                        .padding(.bottom, DSSpacing.sm)

                    turnPill
                        .padding(.top, 18)
                        .padding(.bottom, DSSpacing.xs)

                    board
                        .padding(.horizontal, DSSpacing.xxl)
                        .padding(.vertical, 14)
                }
            }

            actions
                .padding(.horizontal, DSSpacing.xl)
                .padding(.top, DSSpacing.sm)
                .padding(.bottom, DSSpacing.md)
        }
        .background(DSColor.bg.ignoresSafeArea())
        .accessibilityIdentifier("GameScreen")
    }

    // MARK: - Sections

    private var header: some View {
        ScreenHeader(eyebrow: viewModel.headerEyebrow, title: "Tic Tac Toe") {
            CircularIconButton(systemImage: "gearshape.fill", action: onSettingsTap)
                .accessibilityIdentifier("SettingsButton")
        }
    }

    private var scoreboard: some View {
        ScoreboardCard(columns: viewModel.scoreColumnsForUI)
    }

    private var turnPill: some View {
        TurnIndicatorPill(
            letter: viewModel.turnLetter,
            tint: viewModel.turnTint,
            text: viewModel.turnText
        )
    }

    private var board: some View {
        BoardCardContainer {
            VStack(spacing: DSSpacing.sm) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: DSSpacing.sm) {
                        ForEach(0..<3, id: \.self) { column in
                            let position = CellPosition(row: row, column: column)!
                            BoardCellView(state: viewModel.cellState(at: position)) {
                                viewModel.tapCell(at: position)
                            }
                            .accessibilityIdentifier("Cell-\(row)-\(column)")
                        }
                    }
                }
            }
        }
    }

    private var actions: some View {
        VStack(spacing: DSSpacing.md) {
            PrimaryPillButton("New Game") {
                viewModel.newGame()
            }
            .accessibilityIdentifier("NewGameButton")

            TextLinkButton("Undo last move", isEnabled: viewModel.canUndo) {
                viewModel.undo()
            }
            .accessibilityIdentifier("UndoButton")
        }
    }
}

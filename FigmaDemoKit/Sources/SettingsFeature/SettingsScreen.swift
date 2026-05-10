import SwiftUI
import AppPreferences
import DesignSystem
import UIComponents

public struct SettingsScreen: View {
    @Environment(\.dsAccentColor) private var accent
    @State private var viewModel: SettingsViewModel
    private let onBack: () -> Void

    public init(viewModel: SettingsViewModel, onBack: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
    }

    public var body: some View {
        @Bindable var prefs = viewModel.prefs

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                navHeader

                section(eyebrow: "Game") {
                    SettingsCard {
                        labeledSegmentedRow(
                            title: "Difficulty",
                            value: difficultyLabel(prefs.difficulty),
                            selection: $prefs.difficulty,
                            options: difficultyOptions
                        )
                        .accessibilityIdentifier("DifficultyPicker")

                        SettingsCardDivider()

                        labeledSegmentedRow(
                            title: "First Move",
                            value: firstMoveLabel(prefs.firstMove),
                            selection: $prefs.firstMove,
                            options: firstMoveOptions
                        )
                        .accessibilityIdentifier("FirstMovePicker")
                    }
                }

                section(eyebrow: "Appearance") {
                    SettingsCard {
                        labeledSegmentedRow(
                            title: "Theme",
                            value: themeLabel(prefs.theme),
                            selection: $prefs.theme,
                            options: themeOptions
                        )
                        .accessibilityIdentifier("ThemePicker")

                        SettingsCardDivider()

                        accentColorRow(selection: $prefs.accentColor)

                        SettingsCardDivider()

                        DisclosureValueRow(
                            title: "Marker Style",
                            value: markerStyleLabel(prefs.markerStyle),
                            action: {}
                        )
                        .accessibilityIdentifier("MarkerStyleRow")
                    }
                }

                section(eyebrow: "Audio & Haptics") {
                    SettingsCard {
                        ToggleRow(title: "Sound Effects", isOn: $prefs.soundEnabled)
                            .accessibilityIdentifier("SoundEffectsToggle")
                        SettingsCardDivider()
                        ToggleRow(title: "Haptic Feedback", isOn: $prefs.hapticsEnabled)
                            .accessibilityIdentifier("HapticsToggle")
                    }
                }

                resetStatsCard
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.bottom, DSSpacing.xxl)
        }
        .background(DSColor.bg.ignoresSafeArea())
        .accessibilityIdentifier("SettingsScreen")
    }

    // MARK: - Sections

    private var navHeader: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Button(action: onBack) {
                HStack(spacing: 2) {
                    Text("‹")
                        .font(.system(size: 20, weight: .regular))
                    Text("Game")
                        .font(DSFont.bodyEmphasized)
                }
                .foregroundStyle(accent)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("BackToGameButton")

            Text("Settings")
                .font(DSFont.titleLarge)
                .foregroundStyle(DSColor.label)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DSSpacing.sm)
        .padding(.bottom, DSSpacing.md)
    }

    private func section<Content: View>(
        eyebrow: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            EyebrowText(eyebrow)
                .padding(.top, DSSpacing.lg)
            content()
        }
    }

    private var resetStatsCard: some View {
        SettingsCard {
            DestructiveTextRow(title: "Reset Stats") {
                viewModel.resetStats()
            }
            .accessibilityIdentifier("ResetStatsButton")
        }
        .padding(.top, DSSpacing.xl)
    }

    // MARK: - Row builders

    /// Two-line row: title + summary value at top, segmented control below.
    private func labeledSegmentedRow<Value: Hashable>(
        title: String,
        value: String,
        selection: Binding<Value>,
        options: [(value: Value, label: String)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(DSFont.bodyRegular)
                    .foregroundStyle(DSColor.label)
                Spacer()
                Text(value)
                    .font(DSFont.bodyRegular)
                    .foregroundStyle(DSColor.secondary)
            }
            SegmentedPicker(selection: selection, options: options)
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.vertical, DSSpacing.md)
    }

    /// Theme/Accent-style row: title + summary at top, swatch picker below.
    private func accentColorRow(selection: Binding<AccentColor>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Accent Color")
                    .font(DSFont.bodyRegular)
                    .foregroundStyle(DSColor.label)
                Spacer()
                Text(accentColorLabel(selection.wrappedValue))
                    .font(DSFont.bodyRegular)
                    .foregroundStyle(DSColor.secondary)
            }
            AccentSwatchPicker(selection: selection, options: accentSwatchOptions)
                .accessibilityIdentifier("AccentSwatchPicker")
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.vertical, DSSpacing.md)
    }
}

#if os(iOS)
import XCTest
import SwiftUI
import SnapshotTesting
@testable import UIComponents

final class SettingsAtomsSnapshotTests: XCTestCase {
    private let cardWidth: CGFloat = 361

    func test_settingsCard_threeRows() {
        let view = SettingsCard {
            SettingsRow(title: "Difficulty") {
                Text("Medium").foregroundStyle(.secondary)
            }
            SettingsCardDivider()
            SettingsRow(title: "First Move") {
                Text("X").foregroundStyle(.secondary)
            }
            SettingsCardDivider()
            SettingsRow(title: "Theme") {
                Text("System").foregroundStyle(.secondary)
            }
        }
        .frame(width: cardWidth)
        .padding()
        .background(Color(white: 0.95))

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_toggleRow_on() {
        let view = ToggleRow(title: "Sound Effects", isOn: .constant(true))
            .frame(width: cardWidth)

        assertSnapshot(of: view, as: .image(layout: .fixed(width: cardWidth, height: 53)))
    }

    func test_toggleRow_off() {
        let view = ToggleRow(title: "Haptic Feedback", isOn: .constant(false))
            .frame(width: cardWidth)

        assertSnapshot(of: view, as: .image(layout: .fixed(width: cardWidth, height: 53)))
    }

    func test_disclosureValueRow() {
        let view = DisclosureValueRow(title: "Marker Style", value: "Rounded") {}
            .frame(width: cardWidth)

        assertSnapshot(of: view, as: .image(layout: .fixed(width: cardWidth, height: 45)))
    }

    func test_destructiveTextRow() {
        let view = DestructiveTextRow(title: "Reset Stats") {}
            .frame(width: cardWidth)

        assertSnapshot(of: view, as: .image(layout: .fixed(width: cardWidth, height: 45)))
    }

    func test_accentSwatchPicker_blueSelected() {
        let view = AccentSwatchPicker(
            selection: .constant("blue"),
            options: [
                ("blue",   Color(red: 0.0,  green: 0.48, blue: 1.0)),
                ("purple", Color(red: 0.69, green: 0.32, blue: 0.87)),
                ("pink",   Color(red: 1.0,  green: 0.18, blue: 0.33)),
                ("orange", Color(red: 1.0,  green: 0.58, blue: 0.0)),
                ("green",  Color(red: 0.20, green: 0.78, blue: 0.35)),
            ]
        )
        .padding()

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func test_segmentedPicker() {
        struct Host: View {
            @State var selection = "medium"
            var body: some View {
                SegmentedPicker(
                    selection: $selection,
                    options: [("easy", "Easy"), ("medium", "Medium"), ("hard", "Hard")]
                )
                .frame(width: 329)
                .padding()
            }
        }

        assertSnapshot(of: Host(), as: .image(layout: .sizeThatFits))
    }
}
#endif

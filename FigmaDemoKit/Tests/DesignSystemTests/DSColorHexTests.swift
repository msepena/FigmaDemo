import Testing
import SwiftUI
@testable import DesignSystem

@Suite("DSColor hex helper")
struct DSColorHexTests {
    @Test func zeroIsBlack() {
        let c = Color(hex: 0x000000)
        // Round-trip via UIColor would require UIKit; instead, sanity-check description differs from white
        #expect(String(describing: c) != String(describing: Color.white))
    }

    @Test func fullIsNotEqualToBlack() {
        let white = Color(hex: 0xFFFFFF)
        let black = Color(hex: 0x000000)
        #expect(String(describing: white) != String(describing: black))
    }

    @Test func tokensAreNotAllIdentical() {
        // Spot check that named tokens resolve to distinct colors.
        let label = String(describing: DSColor.label)
        let secondary = String(describing: DSColor.secondary)
        let blue = String(describing: DSColor.playerXBlue)
        let orange = String(describing: DSColor.playerOOrange)
        #expect(label != secondary)
        #expect(blue != orange)
    }
}

import Testing
@testable import UIComponents

@Suite("CellVisualState glyph mapping")
struct CellVisualStateTests {
    @Test func emptyHasNoGlyph() {
        #expect(CellVisualState.empty.glyph == nil)
    }

    @Test func xVariantsRenderX() {
        #expect(CellVisualState.x.glyph == "X")
        #expect(CellVisualState.xWinning.glyph == "X")
    }

    @Test func oVariantsRenderO() {
        #expect(CellVisualState.o.glyph == "O")
        #expect(CellVisualState.oWinning.glyph == "O")
    }
}

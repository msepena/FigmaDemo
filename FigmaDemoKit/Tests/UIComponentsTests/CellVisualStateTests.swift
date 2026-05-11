import Testing
@testable import UIComponents

@Suite("CellVisualState mark mapping")
struct CellVisualStateTests {
    @Test func emptyHasNoMark() {
        #expect(CellVisualState.empty.markSide == nil)
    }

    @Test func xVariantsMapToX() {
        #expect(CellVisualState.x.markSide == .x)
        #expect(CellVisualState.xWinning.markSide == .x)
    }

    @Test func oVariantsMapToO() {
        #expect(CellVisualState.o.markSide == .o)
        #expect(CellVisualState.oWinning.markSide == .o)
    }
}

#if os(iOS)
import XCTest
import SwiftUI
import SnapshotTesting
@testable import UIComponents

final class BoardCellViewSnapshotTests: XCTestCase {
    private let cellSize = CGSize(width: 100, height: 100)

    func test_emptyCell() {
        let view = BoardCellView(state: .empty) {}
            .frame(width: cellSize.width, height: cellSize.height)
        assertSnapshot(of: view, as: .image(layout: .fixed(width: cellSize.width, height: cellSize.height)))
    }

    func test_xCell() {
        let view = BoardCellView(state: .x) {}
            .frame(width: cellSize.width, height: cellSize.height)
        assertSnapshot(of: view, as: .image(layout: .fixed(width: cellSize.width, height: cellSize.height)))
    }

    func test_oCell() {
        let view = BoardCellView(state: .o) {}
            .frame(width: cellSize.width, height: cellSize.height)
        assertSnapshot(of: view, as: .image(layout: .fixed(width: cellSize.width, height: cellSize.height)))
    }

    func test_xWinningCell() {
        let view = BoardCellView(state: .xWinning) {}
            .frame(width: cellSize.width, height: cellSize.height)
        assertSnapshot(of: view, as: .image(layout: .fixed(width: cellSize.width, height: cellSize.height)))
    }

    func test_oWinningCell() {
        let view = BoardCellView(state: .oWinning) {}
            .frame(width: cellSize.width, height: cellSize.height)
        assertSnapshot(of: view, as: .image(layout: .fixed(width: cellSize.width, height: cellSize.height)))
    }
}
#endif

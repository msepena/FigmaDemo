//
//  FigmaDemoUITests.swift
//  FigmaDemoUITests
//
//  Created by Hema Sepena on 5/8/26.
//

import XCTest

final class FigmaDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testTappingTopLeftCellPlacesAnX() throws {
        let app = XCUIApplication()
        app.launch()

        let topLeftCell = app.buttons["Cell-0-0"]
        XCTAssertTrue(
            topLeftCell.waitForExistence(timeout: 5),
            "Top-left board cell should be reachable by accessibility identifier"
        )
        // Empty cell renders no glyph, so its accessibility label is empty.
        XCTAssertEqual(topLeftCell.label, "")

        topLeftCell.tap()

        // SwiftUI flattens the cell's inner Text("X") into the button's accessibility label.
        let labelChanged = NSPredicate(format: "label == %@", "X")
        let expectation = XCTNSPredicateExpectation(predicate: labelChanged, object: topLeftCell)
        XCTAssertEqual(
            XCTWaiter.wait(for: [expectation], timeout: 2),
            .completed,
            "Top-left cell's label should become 'X' after being tapped"
        )

        // After X moved, tapping the same cell again must be a no-op (disabled).
        XCTAssertFalse(topLeftCell.isEnabled, "Occupied cell must be disabled")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

import XCTest

/// Scripted tour used only to make the recorded video lively.
/// Every step is guarded, so this test never fails the build.
final class DemoUITests: XCTestCase {

    func testDemoTour() {
        let app = XCUIApplication()
        app.launch()
        pause(2)

        // Explore tab: scroll, open a destination, come back.
        let collection = app.collectionViews.firstMatch
        if collection.waitForExistence(timeout: 15) {
            collection.swipeUp(); pause(1)
            collection.swipeUp(); pause(1)
            collection.swipeDown(); pause(1)
            collection.swipeDown(); pause(1)

            let cell = collection.cells.element(boundBy: 0)
            if cell.exists {
                cell.tap(); pause(2)
                app.swipeUp(); pause(1)
                app.swipeDown(); pause(1)
                let back = app.navigationBars.buttons.element(boundBy: 0)
                if back.exists { back.tap(); pause(1.5) }
            }
        }

        // Packing tab: tick a few items and scroll.
        let packing = app.tabBars.buttons["Packing"]
        if packing.exists {
            packing.tap(); pause(2)
            let table = app.tables.firstMatch
            if table.waitForExistence(timeout: 10) {
                for index in 0..<3 {
                    let row = table.cells.element(boundBy: index)
                    if row.exists { row.tap(); pause(1) }
                }
                table.swipeUp(); pause(1)
                table.swipeDown(); pause(1)
            }
        }

        // Back to Explore.
        let explore = app.tabBars.buttons["Explore"]
        if explore.exists { explore.tap() }
        pause(2)
    }

    private func pause(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }
}

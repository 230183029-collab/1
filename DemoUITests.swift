import XCTest

/// Scripted tour used only to make the recorded video lively.
/// Every step is guarded, so a missing element never stops the tour.
final class DemoUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = true
    }

    func testDemoTour() {
        let app = XCUIApplication()
        app.launch()
        pause(2)

        exploreTour(app)
        packingTour(app)

        // Finish on the Explore tab.
        tap(app.tabBars.buttons["Explore"])
        pause(2)
    }

    // MARK: Explore (UICollectionView)

    private func exploreTour(_ app: XCUIApplication) {
        let collection = app.collectionViews.firstMatch
        guard collection.waitForExistence(timeout: 15) else { return }

        // Scroll through the regions.
        collection.swipeUp(); pause(1)
        collection.swipeUp(); pause(1)
        collection.swipeDown(); pause(1)
        collection.swipeDown(); pause(1)

        // Open a destination, favorite it, add its packing list.
        let cell = collection.cells.element(boundBy: 1)
        if cell.exists {
            cell.tap(); pause(2)
            app.swipeUp(); pause(1)
            tap(app.navigationBars.buttons["Add to favorites"]); pause(1.5)
            tap(app.buttons["Add Packing List"]); pause(1.5)
            app.swipeDown(); pause(1)
            tap(app.navigationBars.buttons.element(boundBy: 0)); pause(1.5)
        }

        // Favorites filter, then back to All.
        let filter = app.segmentedControls.firstMatch
        if filter.exists {
            tap(filter.buttons["Favorites"]); pause(2)
            tap(filter.buttons["All"]); pause(1.5)
        }

        // Touch and hold: context menu on a card.
        let another = collection.cells.element(boundBy: 2)
        if another.exists {
            another.press(forDuration: 1.2); pause(2)
            let menuItem = app.buttons["Add Packing List"]
            if menuItem.exists {
                menuItem.tap()
            } else {
                // Dismiss the menu by tapping an empty spot.
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.04)).tap()
            }
            pause(1.5)
        }

        // "Surprise me" shuffle button.
        let shuffle = app.navigationBars.buttons["Surprise me"]
        if shuffle.exists {
            shuffle.tap(); pause(2)
            tap(app.navigationBars.buttons.element(boundBy: 0)); pause(1.5)
        }
    }

    // MARK: Packing (UITableView)

    private func packingTour(_ app: XCUIApplication) {
        let packing = app.tabBars.buttons["Packing"]
        guard packing.exists else { return }
        packing.tap(); pause(2)

        let table = app.tables.firstMatch
        guard table.waitForExistence(timeout: 10) else { return }

        // Select rows to pack them.
        for index in 0..<3 {
            let row = table.cells.element(boundBy: index)
            if row.exists { row.tap(); pause(1) }
        }

        // Swipe right: pack / unpack.
        let second = table.cells.element(boundBy: 3)
        if second.exists { second.swipeRight(); pause(1.5) }

        // Swipe left: delete.
        let victim = table.cells.element(boundBy: 4)
        if victim.exists {
            victim.swipeLeft(); pause(1.5)
            tap(app.buttons["Delete"]); pause(1.5)
        }

        // Touch and hold: quantity menu.
        let held = table.cells.element(boundBy: 1)
        if held.exists {
            held.press(forDuration: 1.2); pause(2)
            let more = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'One More'")).firstMatch
            if more.exists {
                more.tap()
            } else {
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.04)).tap()
            }
            pause(1.5)
        }

        // Add a new item from the bar button menu.
        let add = app.navigationBars.buttons["Add"]
        if add.exists {
            add.tap(); pause(1.5)
            let category = app.buttons["Documents"]
            if category.waitForExistence(timeout: 3) {
                category.tap(); pause(1.5)
                let alert = app.alerts.firstMatch
                if alert.waitForExistence(timeout: 3) {
                    let field = alert.textFields.firstMatch
                    field.tap(); pause(1)
                    field.typeText("Travel insurance"); pause(1.5)
                    tap(alert.buttons["Add"]); pause(2)
                }
            }
        }

        // Edit mode: reorder rows, then finish.
        let edit = app.navigationBars.buttons["Edit"]
        if edit.exists {
            edit.tap(); pause(2)
            let handle = table.cells.element(boundBy: 0).buttons.matching(
                NSPredicate(format: "label BEGINSWITH 'Reorder'")).firstMatch
            if handle.exists {
                let target = table.cells.element(boundBy: 1).coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.9))
                handle.press(forDuration: 0.6, thenDragTo: target)
                pause(1.5)
            }
            tap(app.navigationBars.buttons["Done"]); pause(1.5)
        }

        table.swipeUp(); pause(1)
        table.swipeDown(); pause(1)
    }

    // MARK: Helpers

    private func tap(_ element: XCUIElement) {
        if element.exists { element.tap() }
    }

    private func pause(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }
}

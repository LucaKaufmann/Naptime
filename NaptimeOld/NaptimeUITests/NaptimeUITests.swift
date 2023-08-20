//
//  NaptimeUITests.swift
//  NaptimeUITests
//
//  Created by Luca Kaufmann on 19.11.2022.
//

import XCTest

final class NaptimeUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.staticTexts["Sleep"].tap()
        snapshot("01HomeScreen")
        app.scrollViews.otherElements.buttons.firstMatch.tap()
        snapshot("EditScreen")
//        app.scrollViews.otherElements.buttons["11:25 - , In progress,  0h 0m 9s"].tap()
        app.navigationBars["_TtGC7SwiftUI19UIHosting"].buttons["Back"].tap()
        app.staticTexts["Wake up"].tap()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

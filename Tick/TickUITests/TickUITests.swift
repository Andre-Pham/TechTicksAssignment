//
//  TickUITests.swift
//  TickUITests
//
//  Created by Andre Pham on 8/3/2024.
//

import XCTest

final class TickUITests: XCTestCase {
    
    // Note to reader:
    // This is a starting point for UI tests. It's by no means exhaustive.
    // It serves a starting point for how a full suite of UI tests would be implemented.
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        
    }
    
    func testCreateTask() throws {
        let newTaskButton = app.otherElements["NEW_TASK_BUTTON"]
        newTaskButton.tap()
        let titleEntry = app.otherElements["TITLE_ENTRY"]
        XCTAssertTrue(titleEntry.exists)
        titleEntry.tap()
        titleEntry.typeText("Task Name")
        let descriptionEntry = app.otherElements["DESCRIPTION_ENTRY"]
        XCTAssertTrue(descriptionEntry.exists)
        descriptionEntry.tap()
        descriptionEntry.typeText("Task Description")
        app.staticTexts["New Task"].tap()
        let saveButton = app.buttons["SAVE_TASK_BUTTON"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        let savedTask = app.staticTexts["Task Description"]
        XCTAssertTrue(savedTask.exists)
    }
    
    func testDeleteTask() throws {
        let savedTask = app.staticTexts["Task Description"].firstMatch
        XCTAssertTrue(savedTask.exists)
        savedTask.press(forDuration: 2.0)
        let contextMenuDeleteButton = app.buttons["Delete"]
        XCTAssertTrue(contextMenuDeleteButton.exists)
        contextMenuDeleteButton.tap()
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

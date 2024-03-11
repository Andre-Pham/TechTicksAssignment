//
//  DatabaseTests.swift
//  DatabaseTests
//
//  Created by Andre Pham on 8/3/2024.
//

import XCTest
@testable import Tick

final class DatabaseTests: XCTestCase {

    override func setUpWithError() throws {
        // Reset the database between tests
        CoreDataController().deleteAllTasks()
    }

    override func tearDownWithError() throws {

    }
    
    func createDummyTests() -> [Task] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let pastDate = dateFormatter.date(from: "2000-01-01 12:00")!
        let futureDate = dateFormatter.date(from: "2050-01-01 12:00")!
        return [
            Task(title: "T1", description: "D1", ongoingDuration: DateInterval(start: pastDate, end: futureDate), markedComplete: false),
            Task(title: "T2", description: "D2", ongoingDuration: DateInterval(start: pastDate, end: futureDate), markedComplete: false),
            Task(title: "T3", description: "D3", ongoingDuration: DateInterval(start: pastDate, end: futureDate), markedComplete: false),
            Task(title: "T3", description: "D3", ongoingDuration: DateInterval(start: futureDate, end: futureDate), markedComplete: false),
            Task(title: "T3", description: "D3", ongoingDuration: DateInterval(start: futureDate, end: futureDate), markedComplete: false),
            Task(title: "T3", description: "D3", ongoingDuration: DateInterval(start: futureDate, end: futureDate), markedComplete: true),
        ]
    }
    
    func populateDatabaseWithDummyTasks(_ controller: CoreDataController) {
        let tasks = self.createDummyTests()
        for task in tasks {
            controller.writeTask(task)
        }
    }

    func testWrite() throws {
        let controller = CoreDataController()
        let tasks = self.createDummyTests()
        for (index, task) in tasks.enumerated() {
            controller.writeTask(task)
            XCTAssert(controller.countTasks() == index + 1)
        }
    }
    
    func testListeners() throws {
        class TestListenerClass: DatabaseListener {
            var listenerType: DatabaseListenerType = .all
            var callbackTriggeredCount = 0
            func onTaskOperation(operations: [DatabaseOperation], tasks: [Task], flags: [DatabaseTaskOperationFlag]) {
                self.callbackTriggeredCount += 1
            }
        }
        let listener = TestListenerClass()
        let controller = CoreDataController()
        controller.addListener(listener: listener)
        XCTAssertEqual(1, listener.callbackTriggeredCount)
        self.populateDatabaseWithDummyTasks(controller)
        let tasksInserted = controller.readAllTasks().count
        XCTAssertEqual(tasksInserted + 1, listener.callbackTriggeredCount)
        controller.removeListener(listener: listener)
        controller.writeTask(Task(title: "T", description: "D", ongoingDuration: DateInterval(start: Date(), duration: 1), markedComplete: false))
        XCTAssertEqual(tasksInserted + 1, listener.callbackTriggeredCount)
    }

    func testDelete() {
        let controller = CoreDataController()
        let tasks = self.createDummyTests()
        for task in tasks {
            controller.writeTask(task)
        }
        let total = tasks.count
        for (index, task) in tasks.enumerated() {
            controller.deleteTask(task)
            XCTAssert(controller.countTasks() == total - index - 1)
        }
        self.populateDatabaseWithDummyTasks(controller)
        XCTAssert(controller.countTasks() > 0)
        controller.deleteAllTasks()
        XCTAssert(controller.countTasks() == 0)
    }
    
    func testEdit() {
        let controller = CoreDataController()
        let task = Task(title: "T", description: "D", ongoingDuration: DateInterval(start: Date(), duration: 1), markedComplete: false)
        controller.writeTask(task)
        let beforeEdit = controller.readAllTasks().first!
        XCTAssertFalse(beforeEdit.markedComplete)
        task.setCompletedStatus(to: true)
        controller.editTask(task)
        let afterEdit = controller.readAllTasks().first!
        XCTAssertTrue(afterEdit.markedComplete)
    }

}

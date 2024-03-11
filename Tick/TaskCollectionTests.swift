//
//  TaskCollectionTests.swift
//  TickTests
//
//  Created by Andre Pham on 11/3/2024.
//

import XCTest
@testable import Tick

final class TaskCollectionTests: XCTestCase {

    override func setUpWithError() throws {

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

    func testTaskStorage() throws {
        let collection = TaskCollection(tasks: self.createDummyTests())
        let newTask = Task(title: "New", description: "Description", ongoingDuration: DateInterval(start: Date(), end: Date()), markedComplete: true)
        XCTAssertNil(collection.getTask(id: newTask.id))
        collection.addTask(newTask)
        XCTAssertNotNil(collection.getTask(id: newTask.id))
    }
    
    func testTaskRetrievalByDate() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let pastDate = dateFormatter.date(from: "2000-01-01 12:00:00")!
        let futureDate = dateFormatter.date(from: "2050-01-01 12:00:00")!
        let offBy59Seconds = dateFormatter.date(from: "2050-01-01 12:00:59")!
        let offBy1Minute = dateFormatter.date(from: "2050-01-01 12:01:00")!
        let collection = TaskCollection(tasks: self.createDummyTests())
        XCTAssert(collection.getTasks(triggeringAt: Date()).isEmpty)
        XCTAssert(collection.getTasks(triggeringAt: pastDate).count == 3)
        XCTAssert(collection.getTasks(triggeringAt: futureDate).count == 3)
        XCTAssert(collection.getTasks(triggeringAt: offBy59Seconds).count == 3)
        XCTAssert(collection.getTasks(triggeringAt: offBy1Minute).isEmpty)
    }
    
    func testSectionedTasks() throws {
        let collection = TaskCollection(tasks: self.createDummyTests())
        // Case 1: No sections
        let noSections = collection.getSectionedTasks(onlyInclude: [])
        XCTAssert(noSections.isEmpty)
        // Case 2: Filter to ongoing tasks
        let ongoing = collection.getSectionedTasks(onlyInclude: [.ongoing])
        XCTAssert(ongoing.count == 1)
        XCTAssert(ongoing[0].status == .ongoing)
        XCTAssert(ongoing[0].tasks.count == 3)
        XCTAssert(ongoing[0].tasks.allSatisfy({ $0.status == .ongoing }))
        // Case 3: Filter to upcoming tasks
        let upcoming = collection.getSectionedTasks(onlyInclude: [.upcoming])
        XCTAssert(upcoming.count == 1)
        XCTAssert(upcoming[0].status == .upcoming)
        XCTAssert(upcoming[0].tasks.count == 2)
        XCTAssert(upcoming[0].tasks.allSatisfy({ $0.status == .upcoming }))
        // Case 4: Filter to completed tasks
        let completed = collection.getSectionedTasks(onlyInclude: [.completed])
        XCTAssert(completed.count == 1)
        XCTAssert(completed[0].status == .completed)
        XCTAssert(completed[0].tasks.count == 1)
        XCTAssert(completed[0].tasks.allSatisfy({ $0.status == .completed }))
        // Case 5: Filter to all sections
        let all = collection.getSectionedTasks(onlyInclude: [.ongoing, .upcoming, .completed])
        XCTAssert(all.count == 3)
        XCTAssert(all[0].status == .ongoing)
        XCTAssert(all[1].status == .upcoming)
        XCTAssert(all[2].status == .completed)
        // Case 6: Empty collection
        let emptyCollection = TaskCollection()
        let empty = emptyCollection.getSectionedTasks(onlyInclude: [.upcoming])
        XCTAssert(empty.count == 1)
        XCTAssert(empty[0].tasks.count == 0)
    }

}

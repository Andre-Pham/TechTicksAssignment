//
//  TaskTests.swift
//  TickTests
//
//  Created by Andre Pham on 11/3/2024.
//

import XCTest
@testable import Tick

final class TaskTests: XCTestCase {

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {
        
    }

    func testStatus() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let pastDate = dateFormatter.date(from: "2000-01-01 12:00")!
        let futureDate = dateFormatter.date(from: "2050-01-01 12:00")!
        var task: Task
        // Case 1: Upcoming task
        task = Task(
            title: "Task Title",
            description: "Task Description",
            ongoingDuration: DateInterval(
                start: futureDate,
                end: futureDate
            ),
            markedComplete: false
        )
        XCTAssert(task.status == .upcoming)
        // Case 2: Ongoing task
        task = Task(
            title: "Task Title",
            description: "Task Description",
            ongoingDuration: DateInterval(
                start: pastDate,
                end: futureDate
            ),
            markedComplete: false
        )
        XCTAssert(task.status == .ongoing)
        // Case 3: Ongoing task for task that's overdue
        task = Task(
            title: "Task Title",
            description: "Task Description",
            ongoingDuration: DateInterval(
                start: pastDate,
                end: pastDate
            ),
            markedComplete: false
        )
        XCTAssert(task.status == .ongoing)
        // Case 4: Completed task on future task
        task = Task(
            title: "Task Title",
            description: "Task Description",
            ongoingDuration: DateInterval(
                start: futureDate,
                end: futureDate
            ),
            markedComplete: true
        )
        XCTAssert(task.status == .completed)
        // Case 5: Completed task on past date
        task = Task(
            title: "Task Title",
            description: "Task Description",
            ongoingDuration: DateInterval(
                start: pastDate,
                end: pastDate
            ),
            markedComplete: true
        )
        XCTAssert(task.status == .completed)
    }
    
    func testMutation() throws {
        let task = Task(
            title: "Task Title",
            description: "Task Description",
            ongoingDuration: DateInterval(
                start: Date(),
                end: Date()
            ),
            markedComplete: true
        )
        XCTAssert(task.markedComplete)
        task.setCompletedStatus(to: false)
        XCTAssertFalse(task.markedComplete)
    }
    
    func testDataMatching() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let earlierDate = dateFormatter.date(from: "2000-01-01 11:59")!
        let date = dateFormatter.date(from: "2000-01-01 12:00")!
        let laterDate = dateFormatter.date(from: "2000-01-01 12:01")!
        // Case 1: Same task
        var task1 = Task(
            title: "Task Title",
            description: "Task Description",
            ongoingDuration: DateInterval(
                start: date,
                end: date
            ),
            markedComplete: true
        )
        var task2 = Task(
            title: "Task Title",
            description: "Task Description",
            ongoingDuration: DateInterval(
                start: date,
                end: date
            ),
            markedComplete: true
        )
        XCTAssert(task1.dataMatches(task: task2))
        // Case 2: Different title
        task2 = Task(
            title: "Task Titl",
            description: "Task Description",
            ongoingDuration: DateInterval(
                start: date,
                end: date
            ),
            markedComplete: true
        )
        XCTAssertFalse(task1.dataMatches(task: task2))
        // Case 3: Different description
        task2 = Task(
            title: "Task Title",
            description: "Task Descriptio",
            ongoingDuration: DateInterval(
                start: date,
                end: date
            ),
            markedComplete: true
        )
        XCTAssertFalse(task1.dataMatches(task: task2))
        // Case 4: Different start
        task2 = Task(
            title: "Task Title",
            description: "Task Description",
            ongoingDuration: DateInterval(
                start: earlierDate,
                end: date
            ),
            markedComplete: true
        )
        XCTAssertFalse(task1.dataMatches(task: task2))
        // Case 5: Different end
        task2 = Task(
            title: "Task Title",
            description: "Task Description",
            ongoingDuration: DateInterval(
                start: date,
                end: laterDate
            ),
            markedComplete: true
        )
        XCTAssertFalse(task1.dataMatches(task: task2))
        // Case 6: Different completion status
        task2 = Task(
            title: "Task Title",
            description: "Task Description",
            ongoingDuration: DateInterval(
                start: date,
                end: date
            ),
            markedComplete: false
        )
        XCTAssertFalse(task1.dataMatches(task: task2))
    }

}

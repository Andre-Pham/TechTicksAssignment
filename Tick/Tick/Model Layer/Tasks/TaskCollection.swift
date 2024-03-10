//
//  TaskCollection.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation

/// A data structure for storing, organising, and retrieving tasks.
class TaskCollection {
    
    /// Represents a section of all the tasks as a whole, identified by status
    public typealias TaskSection = (status: TaskStatus, tasks: [Task])
    
    /// The collection of tasks
    private var tasks: [Task]
    
    init(tasks: [Task] = []) {
        self.tasks = tasks
    }
    
    /// Add a task to the collection
    /// - Parameters:
    ///   - task: The task to add
    func addTask(_ task: Task) {
        self.tasks.append(task)
    }
    
    /// Get a task by id (if available)
    /// - Parameters:
    ///   - id: The id of the task to retrieve
    /// - Returns: The task with the matching id, if found
    func getTask(id: UUID) -> Task? {
        return self.tasks.first(where: { $0.id == id })
    }
    
    /// Gets all tasks that trigger exactly at a certain date/time
    /// (Accurate to the minute)
    /// - Parameters:
    ///   - triggeringAt: The date/time to filter by
    /// - Returns: All tasks that start at the provided date/time
    func getTasks(triggeringAt: Date) -> [Task] {
        let calendar = Calendar.current
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        let triggerComponents = calendar.dateComponents(components, from: triggeringAt)
        return self.tasks.filter({
            let taskComponents = calendar.dateComponents(components, from: $0.ongoingDuration.start)
            return triggerComponents == taskComponents
        })
    }
    
    /// Groups tasks by status and returns each grouping in an array
    /// - Parameters:
    ///   - onlyInclude: The task status' to include in the result
    /// - Returns: The array of task groupings - will always be the same length as the `onlyInclude` argument
    func getSectionedTasks(onlyInclude: [TaskStatus]) -> [TaskSection] {
        var result = [TaskSection]()
        for status in onlyInclude {
            let section = self.tasks.filter({ $0.status == status })
            result.append(TaskSection(status: status, tasks: section))
        }
        return result
    }
    
}

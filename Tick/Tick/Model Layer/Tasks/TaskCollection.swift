//
//  TaskCollection.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation

class TaskCollection {
    
    public typealias TaskSection = (status: TaskStatus, tasks: [Task])
    
    private var tasks: [Task]
    
    init(tasks: [Task] = []) {
        self.tasks = tasks
    }
    
    func addTask(_ task: Task) {
        self.tasks.append(task)
    }
    
    func getTask(id: UUID) -> Task? {
        return self.tasks.first(where: { $0.id == id })
    }
    
    func getTasks(triggeringAt: Date) -> [Task] {
        let calendar = Calendar.current
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        let triggerComponents = calendar.dateComponents(components, from: triggeringAt)
        return self.tasks.filter({
            let taskComponents = calendar.dateComponents(components, from: $0.ongoingDuration.start)
            return triggerComponents == taskComponents
        })
    }
    
    func getSectionedTasks(onlyInclude: [TaskStatus]) -> [TaskSection] {
        var result = [TaskSection]()
        for status in onlyInclude {
            let section = self.tasks.filter({ $0.status == status })
            result.append(TaskSection(status: status, tasks: section))
        }
        return result
    }
    
}

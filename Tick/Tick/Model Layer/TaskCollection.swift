//
//  TaskCollection.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation

class TaskCollection {
    
    public typealias TaskGrouping = (status: TaskStatus, grouping: [Task])
    
    private var tasks: [Task]
    
    init(tasks: [Task] = []) {
        self.tasks = tasks
    }
    
    func addTask(_ task: Task) {
        self.tasks.append(task)
    }
    
    func getSectionedTasks(onlyInclude: [TaskStatus]) -> [TaskGrouping] {
        var result = [TaskGrouping]()
        for status in onlyInclude {
            let section = self.tasks.filter({ $0.status == status })
            result.append(TaskGrouping(status: status, grouping: section))
        }
        return result
    }
    
}

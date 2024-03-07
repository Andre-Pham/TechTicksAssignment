//
//  TaskCollection.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation

class TaskCollection {
    
    private var tasks = [Task]()
    
    init() { }
    
    func addTask(_ task: Task) {
        self.tasks.append(task)
    }
    
    func getSectionedTasks(onlyInclude: [TaskStatus]) -> [[Task]] {
        var result = [[Task]]()
        for status in onlyInclude {
            let section = self.tasks.filter({ $0.status == status })
            result.append(section)
        }
        return result
    }
    
}

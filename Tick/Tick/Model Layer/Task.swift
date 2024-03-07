//
//  Task.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation

class Task {
    
    private(set) var title: String
    private(set) var description: String
    private(set) var startDate: Date
    private(set) var endDate: Date
    private(set) var markedComplete: Bool
    public var status: TaskStatus {
        if self.markedComplete {
            return .completed
        }
        let now = Date()
        let nowIsBeforeStartDate = now < self.startDate
        return nowIsBeforeStartDate ? .upcoming : .ongoing
    }
    public var canBeEdited: Bool {
        return self.status == .ongoing
    }
    
    init(title: String, description: String, startDate: Date, endDate: Date, markedComplete: Bool) {
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.markedComplete = markedComplete
    }
    
}

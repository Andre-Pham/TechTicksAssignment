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
    private(set) var ongoingDuration: DateInterval
    private(set) var markedComplete: Bool
    public var status: TaskStatus {
        if self.markedComplete {
            return .completed
        }
        let nowIsBeforeStartDate = Date() < self.ongoingDuration.start
        return nowIsBeforeStartDate ? .upcoming : .ongoing
    }
    public var canBeEdited: Bool {
        return self.status == .ongoing
    }
    
    init(title: String, description: String, ongoingDuration: DateInterval, markedComplete: Bool) {
        self.title = title
        self.description = description
        self.ongoingDuration = ongoingDuration
        self.markedComplete = markedComplete
    }
    
}

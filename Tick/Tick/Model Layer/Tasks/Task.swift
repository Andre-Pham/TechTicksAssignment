//
//  Task.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import CoreData

class Task: ManagedObjectStorable, Identifiable {
    
    public let id: UUID
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
    public var canBeChecked: Bool {
        return self.status == .ongoing || self.status == .completed
    }
    public var formattedOngoingDuration: String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E d MMM" // For day part
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a" // For time part
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        let startDay = dayFormatter.string(from: self.ongoingDuration.start)
        let startTime = timeFormatter.string(from: self.ongoingDuration.start)
        let endDay = dayFormatter.string(from: self.ongoingDuration.end)
        let endTime = timeFormatter.string(from: self.ongoingDuration.end)
        let formattedInterval: String
        if startDay == endDay {
            // If the start and end days are the same, you might want to format it differently
            formattedInterval = "\(startDay) \(startTime) - \(endTime)"
        } else {
            formattedInterval = "\(startDay) \(startTime) - \(endDay) \(endTime)"
        }
        return formattedInterval
    }
    
    init(id: UUID = UUID(), title: String, description: String, ongoingDuration: DateInterval, markedComplete: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.ongoingDuration = ongoingDuration
        self.markedComplete = markedComplete
    }
    
    func setCompletedStatus(to completed: Bool) {
        guard self.canBeChecked else {
            return
        }
        self.markedComplete = completed
    }
    
    func dataMatches(task: Task) -> Bool {
        return (
            self.title == task.title
            && self.description == task.description
            && self.ongoingDuration == task.ongoingDuration
            && self.markedComplete == task.markedComplete
        )
    }
    
    // MARK: - ManagedObjectStorable
    
    public enum StorableAttributes: String {
        case id = "taskID"
        case title = "taskTitle"
        case description = "taskDescription"
        case start = "taskStart"
        case end = "taskEnd"
        case markedComplete = "taskMarkedComplete"
    }
    
    public static let ENTITY_NAME = "TaskEntity"
    
    required init?(_ managedObject: NSManagedObject) {
        guard let id = managedObject.value(forKey: StorableAttributes.id.rawValue) as? UUID,
              let title = managedObject.value(forKey: StorableAttributes.title.rawValue) as? String,
              let description = managedObject.value(forKey: StorableAttributes.description.rawValue) as? String,
              let start = managedObject.value(forKey: StorableAttributes.start.rawValue) as? Date,
              let end = managedObject.value(forKey: StorableAttributes.end.rawValue) as? Date,
              let markedComplete = managedObject.value(forKey: StorableAttributes.markedComplete.rawValue) as? Bool else {
            return nil
        }
        self.id = id
        self.title = title
        self.description = description
        self.ongoingDuration = DateInterval(start: start, end: end)
        self.markedComplete = markedComplete
    }
    
    func populateManagedObject(_ managedObject: NSManagedObject) {
        managedObject.setValue(self.id, forKey: StorableAttributes.id.rawValue)
        managedObject.setValue(self.title, forKey: StorableAttributes.title.rawValue)
        managedObject.setValue(self.description, forKey: StorableAttributes.description.rawValue)
        managedObject.setValue(self.ongoingDuration.start, forKey: StorableAttributes.start.rawValue)
        managedObject.setValue(self.ongoingDuration.end, forKey: StorableAttributes.end.rawValue)
        managedObject.setValue(self.markedComplete, forKey: StorableAttributes.markedComplete.rawValue)
    }
    
}

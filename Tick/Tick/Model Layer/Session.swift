//
//  Session.swift
//  Tick
//
//  Created by Andre Pham on 10/3/2024.
//

import Foundation
import UIKit

/// Effectively the "brains" of the app that allows controllers to access and invoke business logic.
class Session {
    
    /// Singleton instance
    public static let inst = Session()
    /// The local database instance to make CRUD operations to
    private let databaseController: LocalDatabase
    
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("App delegate required, something is seriously wrong - bail")
        }
        guard let databaseController = appDelegate.databaseController else {
            fatalError("Database controller failed to be instantiated on launch - bail")
        }
        self.databaseController = databaseController
    }
    
    /// Adds a listener to the database to receive callbacks from changes
    /// - Parameters:
    ///   - listener: The object to listen to database changes
    func listenToDatabase(_ listener: DatabaseListener) {
        self.databaseController.addListener(listener: listener)
    }
    
    /// Removes a listener from the database
    /// - Parameters:
    ///   - listener: The listener object to remove
    func endListenToDatabase(_ listener: DatabaseListener) {
        self.databaseController.removeListener(listener: listener)
    }
    
    /// Reads all tasks from persistent storage
    /// - Returns: The read tasks
    func readAllTasks() -> [Task] {
        return self.databaseController.readAllTasks()
    }
    
    /// Writes a task to persistent storage
    /// - Parameters:
    ///   - task: The task to write
    func createTask(_ task: Task) {
        self.databaseController.writeTask(task, flags: [.taskCreation])
        self.scheduleTaskNotification(task)
    }
    
    /// Edits a task in persistent storage (intended for task completion ONLY)
    /// - Parameters:
    ///   - task: The task to edit
    func editTaskCompletion(_ task: Task) {
        self.databaseController.editTask(task, flags: [.taskCompletionEdit])
    }
    
    /// Edits a task in persistent storage
    /// - Parameters:
    ///   - task: The task to edit
    func editTaskContent(_ task: Task) {
        self.databaseController.editTask(task, flags: [.taskContentEdit])
        LocalNotificationsController.inst.removeNotification(id: task.id.uuidString)
        self.scheduleTaskNotification(task)
    }
    
    /// Deletes a task in persistent storage
    /// - Parameters:
    ///   - task: The task to delete
    func deleteTask(_ task: Task) {
        self.databaseController.deleteTask(task, flags: [.taskDeletion])
        LocalNotificationsController.inst.removeNotification(id: task.id.uuidString)
    }
    
    /// Schedule a notification for a task
    /// - Parameters:
    ///   - task: The task to schedule a notification for
    private func scheduleTaskNotification(_ task: Task) {
        LocalNotificationsController.inst.scheduleNotification(
            id: task.id.uuidString,
            title: task.title,
            body: task.description,
            trigger: task.ongoingDuration.start
        )
    }
    
}

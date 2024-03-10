//
//  Session.swift
//  Tick
//
//  Created by Andre Pham on 10/3/2024.
//

import Foundation
import UIKit

class Session {
    
    /// Singleton instance
    public static let inst = Session()
    /// The local database instance to made  CRUD operations to
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
    
    func listenToDatabase(_ listener: DatabaseListener) {
        self.databaseController.addListener(listener: listener)
    }
    
    func endListenToDatabase(_ listener: DatabaseListener) {
        self.databaseController.removeListener(listener: listener)
    }
    
    func readAllTasks() -> [Task] {
        return self.databaseController.readAllTasks()
    }
    
    func createTask(_ task: Task) {
        self.databaseController.writeTask(task, flags: [.taskCreation])
        self.scheduleTaskNotification(task)
    }
    
    func editTaskCompletion(_ task: Task) {
        self.databaseController.editTask(task, flags: [.taskCompletionEdit])
    }
    
    func editTaskContent(_ task: Task) {
        self.databaseController.editTask(task, flags: [.taskContentEdit])
        LocalNotificationsController.inst.removeNotification(id: task.id.uuidString)
        self.scheduleTaskNotification(task)
    }
    
    func deleteTask(_ task: Task) {
        self.databaseController.deleteTask(task, flags: [.taskDeletion])
        LocalNotificationsController.inst.removeNotification(id: task.id.uuidString)
    }
    
    private func scheduleTaskNotification(_ task: Task) {
        LocalNotificationsController.inst.scheduleNotification(
            id: task.id.uuidString,
            title: task.title,
            body: task.description,
            trigger: task.ongoingDuration.start
        )
    }
    
}

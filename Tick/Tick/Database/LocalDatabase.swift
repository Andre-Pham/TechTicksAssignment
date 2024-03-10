//
//  LocalDatabase.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation

/// A protocol for any local database implementation.
/// See Adapter (aka Wrapper) pattern.
protocol LocalDatabase: AnyObject {
    
    /// Register as a listener to the database to receive callbacks from changes
    /// - Parameters:
    ///   - listener: The object to listen to database changes
    func addListener(listener: DatabaseListener)
    
    /// De-register a listener from the database
    /// - Parameters:
    ///   - listener: The listener object to de-register
    func removeListener(listener: DatabaseListener)
    
    /// Reads all tasks from persistent storage
    /// - Returns: The read tasks
    func readAllTasks() -> [Task]
    
    /// Writes a task to persistent storage
    /// - Parameters:
    ///   - task: The task to write
    ///   - flags: Any flags to be associated with the operation (to be received by listeners)
    func writeTask(_ task: Task, flags: [DatabaseTaskOperationFlag])
    
    /// Deletes a task in persistent storage
    /// - Parameters:
    ///   - task: The task to delete
    ///   - flags: Any flags to be associated with the operation (to be received by listeners)
    func deleteTask(_ task: Task, flags: [DatabaseTaskOperationFlag])
    
    /// Deletes all tasks in persistent storage
    /// - Parameters:
    ///   - flags: Any flags to be associated with the operation (to be received by listeners)
    func deleteAllTasks(flags: [DatabaseTaskOperationFlag])
    
    /// Counts all tasks in persistent storage
    /// - Returns: The number of tasks saved
    func countTasks() -> Int
    
    /// Edits a task in persistent storage
    /// - Parameters:
    ///   - task: The task to edit
    ///   - flags: Any flags to be associated with the operation (to be received by listeners)
    func editTask(_ task: Task, flags: [DatabaseTaskOperationFlag])
    
}

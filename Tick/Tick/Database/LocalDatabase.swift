//
//  LocalDatabase.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation

protocol LocalDatabase: AnyObject {
    
    func saveChanges()
    func saveChildToParent()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func readAllTasks() -> [Task]
    func writeTask(_ task: Task, flags: [DatabaseTaskOperationFlag])
    func deleteTask(_ task: Task, flags: [DatabaseTaskOperationFlag])
    func countTasks() -> Int
    func editTask(_ task: Task, flags: [DatabaseTaskOperationFlag])
    
}

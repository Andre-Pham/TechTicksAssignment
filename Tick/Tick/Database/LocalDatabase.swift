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
    
    func writeTask(_ task: Task)
    func deleteTask(_ task: Task)
    func countTasks() -> Int
    func editTask(_ task: Task)
    
}

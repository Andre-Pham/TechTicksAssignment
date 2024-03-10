//
//  DatabaseTaskOperationFlag.swift
//  Tick
//
//  Created by Andre Pham on 10/3/2024.
//

import Foundation

/// Flags that can be associated with database operations.
enum DatabaseTaskOperationFlag {
    
    /// Indicates a task's content (title, description, start/end date, etc.) was edited
    case taskContentEdit
    /// Indicates a task was created
    case taskCreation
    /// Indicates a task was edited via marking it complete/incomplete (and no other edits)
    case taskCompletionEdit
    /// Indicates a task was deleted
    case taskDeletion
    
}

//
//  DatabaseOperation.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation

/// The types of database operations. Gives context to listeners on what they're responding to.
/// Reads don't trigger listener callbacks so they're not included.
enum DatabaseOperation {
    
    case write
    case delete
    case update
    
}

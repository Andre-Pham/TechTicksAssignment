//
//  DatabaseListener.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation

/// Conforming objects get callbacks from database operations
/// IMPORTANT: Object must first after register to the database using `LocalDatabase.addListener(:DatabaseListener)`
protocol DatabaseListener {
    
    /// What types of callbacks to receive
    var listenerType: DatabaseListenerType { get set }
    
    /// The callback for any changes to the tasks stored in the database
    /// - Parameters:
    ///   - operation: The operation type that triggered the callback
    ///   - tasks: All the tasks stored in the database after the operation's changes
    ///   - flags: Any flags associated with the operation to inform how this responder behaves
    func onTaskOperation(operations: [DatabaseOperation], tasks: [Task], flags: [DatabaseTaskOperationFlag])
    
}

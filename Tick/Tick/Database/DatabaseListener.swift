//
//  DatabaseListener.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation

protocol DatabaseListener {
    
    var listenerType: DatabaseListenerType { get set }
    
    func onTaskOperation(operation: DatabaseOperation, tasks: [Task])
    
}

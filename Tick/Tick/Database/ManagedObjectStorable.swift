//
//  ManagedObjectStorable.swift
//  Tick
//
//  Created by Andre Pham on 9/3/2024.
//

import Foundation
import CoreData

/// A protocol for objects to conform to to allow them to be serialised and restored from Core Data as NSManagedObjects
protocol ManagedObjectStorable {
    
    /// A required enum field on the entity and object's attribtues
    /// Must be public - this way Core Data can reference the attributes for queries such as NSSortDescriptor and NSPredicate
    associatedtype StorableAttributes: RawRepresentable where StorableAttributes.RawValue == String
    
    /// The object's corresponding entity name in Core Data
    static var ENTITY_NAME: String { get }
    
    init?(_ managedObject: NSManagedObject)
    
    /// Serialises the object's data into a managed object
    /// Must store all attributes that are required for the object to be restored
    /// - Parameters:
    ///   - managedObject: The managed object for the object to store its data in
    func populateManagedObject(_ managedObject: NSManagedObject)
    
}

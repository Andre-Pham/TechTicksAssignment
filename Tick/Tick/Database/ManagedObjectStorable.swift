//
//  ManagedObjectStorable.swift
//  Tick
//
//  Created by Andre Pham on 9/3/2024.
//

import Foundation
import CoreData

protocol ManagedObjectStorable {
    
    associatedtype StorableAttributes: RawRepresentable where StorableAttributes.RawValue == String
    
    static var ENTITY_NAME: String { get }
    
    init?(_ managedObject: NSManagedObject)
    
    func populateManagedObject(_ managedObject: NSManagedObject)
    
}

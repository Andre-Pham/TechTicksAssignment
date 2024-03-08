//
//  CoreDataController.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import CoreData

class CoreDataController: NSObject {
    
    private static let DATA_MODEL_NAME = "TickDataModel"
    
    // MARK: - Properties
    
    // FetchedResultsControllers
    var allTickTasksFetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
    // Other properties
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var childManagedContext: NSManagedObjectContext
    
    // MARK: - Constructor
    
    override init() {
        // Define persistent container
        self.persistentContainer = NSPersistentContainer(name: Self.DATA_MODEL_NAME)
        self.persistentContainer.loadPersistentStores() {
            (description, error) in if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        
        // Initiate Child Managed Context
        self.childManagedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.childManagedContext.parent = self.persistentContainer.viewContext
        
        super.init()
    }
    
    func readAllTasks() -> [Task] {
        if self.allTickTasksFetchedResultsController == nil {
            // Instantiate fetch request
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Task.ENTITY_NAME)
            let nameSortDescriptor = NSSortDescriptor(key: Task.StorableAttributes.start.rawValue, ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            self.allTickTasksFetchedResultsController = NSFetchedResultsController<NSManagedObject>(
                fetchRequest: fetchRequest,
                managedObjectContext: self.persistentContainer.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            self.allTickTasksFetchedResultsController?.delegate = self
            do {
                try self.allTickTasksFetchedResultsController?.performFetch()
            } catch {
                assertionFailure("Fetch request failed: \(error)")
            }
        }
        guard let fetchedTasks = self.allTickTasksFetchedResultsController?.fetchedObjects else {
            assertionFailure("Fetch request should have been instantiated but wasn't")
            return [Task]()
        }
        return fetchedTasks.compactMap({ managedObject in
            return Task(managedObject)
        })
    }
    
}
extension CoreDataController: LocalDatabase {
    
    /// Checks if there are changes to be saved inside of the view context and then saves, if necessary
    func saveChanges() {
        if self.persistentContainer.viewContext.hasChanges {
            do {
                try self.persistentContainer.viewContext.save()
            } catch {
                assertionFailure("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    /// Saves the child context, hence pushing the changes to the parent context
    func saveChildToParent() {
        do {
            // Saving child managed context pushes it to Core Data
            try self.childManagedContext.save()
        }
        catch {
            assertionFailure("Failed to save child managed context to Core Data with error: \(error)")
        }
    }
    
    /// Creates a new listener that either fetches all meals or ingredients
    func addListener(listener: DatabaseListener) {
        // Adds the new database listener to the list of listeners
        self.listeners.addDelegate(listener)
        
        // Provides the listener with the initial immediate results depending on the type
        if listener.listenerType == .task || listener.listenerType == .all {
            listener.onTaskOperation(operation: .update, tasks: self.readAllTasks())
        }
    }
    
    /// Removes a specific listener
    func removeListener(listener: DatabaseListener) {
        self.listeners.removeDelegate(listener)
    }
    
    func writeTask(_ task: Task) {
        let context = self.persistentContainer.viewContext
        let taskEntity = NSEntityDescription.entity(forEntityName: Task.ENTITY_NAME, in: context)!
        let managedObject = NSManagedObject(entity: taskEntity, insertInto: context)
        task.populateManagedObject(managedObject)
        do {
            try context.save()
        } catch let error as NSError {
            assertionFailure("Could not write task with error: \(error), \(error.userInfo)")
        }
    }
    
    func deleteTask(_ task: Task) {
        let context = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Task.ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "\(Task.StorableAttributes.id.rawValue) == %@", task.id as CVarArg)
        do {
            let tasks = try context.fetch(fetchRequest)
            if let taskToDelete = tasks.first as? NSManagedObject {
                context.delete(taskToDelete)
                try context.save()
            }
        } catch let error as NSError {
            print("Could not delete task with error: \(error), \(error.userInfo)")
        }
    }
    
    func editTask(_ task: Task) {
        let context = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Task.ENTITY_NAME)
        fetchRequest.predicate = NSPredicate(format: "\(Task.StorableAttributes.id.rawValue) == %@", task.id as CVarArg)
        do {
            let tasks = try context.fetch(fetchRequest)
            if let taskToEdit = tasks.first as? NSManagedObject {
                task.populateManagedObject(taskToEdit)
                try context.save()
            }
        } catch let error as NSError {
            print("Could not edit task with error: \(error), \(error.userInfo)")
        }
    }
    
    func countTasks() -> Int {
        return self.readAllTasks().count
    }
    
}
extension CoreDataController: NSFetchedResultsControllerDelegate {
    
    /// Called whenever the FetchedResultsController detects a change to the result of its fetch
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allTickTasksFetchedResultsController {
            self.listeners.invoke() { listener in
                if listener.listenerType == .task || listener.listenerType == .all {
                    listener.onTaskOperation(operation: .update, tasks: self.readAllTasks())
                }
            }
        }
    }
    
}

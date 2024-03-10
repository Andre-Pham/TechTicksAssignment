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
    private var allTasksFetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    private var allTasksFetchedResultsOperationFlags = [DatabaseTaskOperationFlag]()
    
    // Other properties
    private var listeners = MulticastDelegate<DatabaseListener>()
    private var persistentContainer: NSPersistentContainer
    private var childManagedContext: NSManagedObjectContext
    
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
            listener.onTaskOperation(operation: .update, tasks: self.readAllTasks(), flags: [])
        }
    }
    
    /// Removes a specific listener
    func removeListener(listener: DatabaseListener) {
        self.listeners.removeDelegate(listener)
    }
    
    func readAllTasks() -> [Task] {
        if self.allTasksFetchedResultsController == nil {
            // Instantiate fetch request
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Task.ENTITY_NAME)
            let nameSortDescriptor = NSSortDescriptor(key: Task.StorableAttributes.start.rawValue, ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            self.allTasksFetchedResultsController = NSFetchedResultsController<NSManagedObject>(
                fetchRequest: fetchRequest,
                managedObjectContext: self.persistentContainer.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            self.allTasksFetchedResultsController?.delegate = self
            do {
                try self.allTasksFetchedResultsController?.performFetch()
            } catch {
                assertionFailure("Fetch request failed: \(error)")
            }
        }
        guard let fetchedTasks = self.allTasksFetchedResultsController?.fetchedObjects else {
            assertionFailure("Fetch request should have been instantiated but wasn't")
            return [Task]()
        }
        return fetchedTasks.compactMap({ managedObject in
            return Task(managedObject)
        })
    }
    
    func writeTask(_ task: Task, flags: [DatabaseTaskOperationFlag] = []) {
        self.allTasksFetchedResultsOperationFlags = flags
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
    
    func deleteTask(_ task: Task, flags: [DatabaseTaskOperationFlag] = []) {
        self.allTasksFetchedResultsOperationFlags = flags
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
    
    func deleteAllTasks(flags: [DatabaseTaskOperationFlag] = []) {
        self.allTasksFetchedResultsOperationFlags = flags
        let context = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Task.ENTITY_NAME)
        fetchRequest.includesPropertyValues = false
        do {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            // Save the context to persist changes
            try context.save()
        } catch let error as NSError {
            assertionFailure("Could not delete all tasks with error: \(error), \(error.userInfo)")
        }
    }
    
    func editTask(_ task: Task, flags: [DatabaseTaskOperationFlag] = []) {
        self.allTasksFetchedResultsOperationFlags = flags
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
    
    // TODO: Replace with this
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("Object was added")
        case .delete:
            print("Object was deleted")
        case .update:
            print("Object was updated")
        case .move:
            print("Object was moved")
        @unknown default:
            fatalError("Unhandled change type: \(type)")
        }
    }
    
    /// Called whenever the FetchedResultsController detects a change to the result of its fetch
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == self.allTasksFetchedResultsController {
            self.listeners.invoke() { listener in
                if listener.listenerType == .task || listener.listenerType == .all {
                    listener.onTaskOperation(operation: .update, tasks: self.readAllTasks(), flags: self.allTasksFetchedResultsOperationFlags)
                }
            }
        }
    }
    
}

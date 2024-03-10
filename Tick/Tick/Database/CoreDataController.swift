//
//  CoreDataController.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import CoreData

class CoreDataController: NSObject {
    
    // MARK: - Constants
    
    private static let DATA_MODEL_NAME = "TickDataModel"
    
    // MARK: - Properties
    
    /// Cached fetched results controller - stores fetched Task entity NSManagedObjects
    private var allTasksFetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    /// The operation flags associated with the last operation (reset on every operation)
    private var allTasksFetchedResultsOperationFlags = [DatabaseTaskOperationFlag]()
    /// Database listeners (this notifies them of any changes to the fetched results controller)
    private var listeners = MulticastDelegate<DatabaseListener>()
    /// The persistent container reference for the associated data model
    private var persistentContainer: NSPersistentContainer
    /// The child managed context
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
    
    /// Register as a listener to the database to receive callbacks from changes
    /// - Parameters:
    ///   - listener: The object to listen to database changes
    func addListener(listener: DatabaseListener) {
        self.listeners.addDelegate(listener)
        // Provides the listener with the initial immediate results
        if listener.listenerType == .task || listener.listenerType == .all {
            listener.onTaskOperation(operation: .update, tasks: self.readAllTasks(), flags: [])
        }
    }
    
    /// De-register a listener from the database
    /// - Parameters:
    ///   - listener: The listener object to de-register
    func removeListener(listener: DatabaseListener) {
        self.listeners.removeDelegate(listener)
    }
    
    /// Reads all tasks from persistent storage
    /// - Returns: The read tasks
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
    
    /// Writes a task to persistent storage
    /// - Parameters:
    ///   - task: The task to write
    ///   - flags: Any flags to be associated with the operation (to be received by listeners)
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
    
    /// Deletes a task in persistent storage
    /// - Parameters:
    ///   - task: The task to delete
    ///   - flags: Any flags to be associated with the operation (to be received by listeners)
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
    
    /// Deletes all tasks in persistent storage
    /// - Parameters:
    ///   - flags: Any flags to be associated with the operation (to be received by listeners)
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
    
    /// Edits a task in persistent storage
    /// - Parameters:
    ///   - task: The task to edit
    ///   - flags: Any flags to be associated with the operation (to be received by listeners)
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
    
    /// Counts all tasks in persistent storage
    /// - Returns: The number of tasks saved
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

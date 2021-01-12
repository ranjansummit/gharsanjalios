//
//  CoreDataStack.swift
//  Magnify
//
//  Created by Nishan-82 on 6/28/17.
//  Copyright © 2017 andmine. All rights reserved.
//

import Foundation
import CoreData


class CoreDataStack {
    
    static let modelName = "BhatBhate"
    
    /*----------------------------
     MARK:- CoreDataStack ios < 10
     -----------------------------*/
    
    // Helper for accessing application 'Documents' directory.
    private lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        return urls [urls.count - 1]
        
    }()
    
    /*
     Xcode has generated a file named CoreData_Helper.xcdatamodeld. This is the data model of the application that is 'compiled to an .momd file'
     
     That .momd file is used by NSManagedObjectModel to create data model for the application.
     */
    private lazy var managedObjectModel : NSManagedObjectModel = {
        
        let modelURL = Bundle.main.url(forResource: CoreDataStack.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        
    }()
    
    
    private lazy var persistentStoreCoordinator : NSPersistentStoreCoordinator = {
        
        // Creating persistent store coordinator for provided managed object model
        let coordinator:NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let failureReason = "There was an error creating or loading the application's saved data"
        
        // Creating persistent store backed by sqlite.
        let url = self.applicationDocumentsDirectory.appendingPathComponent("\(CoreDataStack.modelName).sqlite")
        
        do {
            /*
             Adding persistent store to persistent store coordinator. Core Data also supports binary
             stores NSBinaryStoreType and in memory store NSInMemoryStoreType.
             */
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            
        } catch {
            
            var errorDict = [String:Any]()
            errorDict[NSLocalizedDescriptionKey] = "Failed to initialize application saved data"
            errorDict[NSLocalizedFailureReasonErrorKey] = failureReason
            errorDict[NSUnderlyingErrorKey] = error
            
            let error = NSError(domain: "Magnify", code: 9999, userInfo: errorDict)
            NSLog("\(error)", error.userInfo)
            
            abort()         // FIXME: Remove abort from production code
        }
        
        return coordinator
        
    }()
    
    // Creates a 'NSManagedObjectContext' and set it's the 'NSPersistentStoreCoordinator'
    private lazy var managedObjectContext : NSManagedObjectContext = {
        
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        
    }()

    /*-------------------------------
     MARK:- Coredata ios 10+ support
     -------------------------------*/
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: CoreDataStack.modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context:NSManagedObjectContext {
        
        get {
            if #available(iOS 10.0, *) {
                return persistentContainer.viewContext
            } else {
                return managedObjectContext
            }
        }
    }
    
    func saveContext() {
        
        if context.hasChanges {
            
            do {
                try context.save()
            } catch {
                
                Log.warn(info: "Aborting with error \(error)")
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                
            }
            
        }
    }
    
}


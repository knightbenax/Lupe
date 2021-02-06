//
//  Store.swift
//  Fett
//
//  Created by Bezaleel Ashefor on 02/01/2021.
//

import Foundation
import CoreData
import UIKit

class StoreHelper {
    
    
    let suite = "group.com.ephod.Lupe"
    
    func setFirstTimeValue(){
        if (UserDefaults(suiteName: suite)!.object(forKey: "first_time") == nil){
            saveFirstTimeValue(value: true)
        }
    }
    
    func saveFirstTimeValue(value: Bool){
        UserDefaults(suiteName: suite)!.set(value, forKey: "first_time")
    }
    
    func getFirstTimeValue() -> Bool{
        return UserDefaults(suiteName: suite)!.bool(forKey: "first_time")
    }
    
    func getDrawings(delegate: AppDelegate) -> [DrawingModel]{
        var drawings : [NSManagedObject] = []
        var drawingModels = [DrawingModel]()
        
        let managedContext = delegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Drawing")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        
        do {
            try drawings = managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Couldn't retrieve shit \(error), \(error.userInfo)")
        }
        
        drawings.forEach({
            drawingModels.append(DrawingModel(dateModified: $0.value(forKey: "dateModified") as! Date,
                                              dateCreated: $0.value(forKey: "dateCreated") as! Date,
                                              drawingEntity: $0.value(forKey: "drawingObject") as! String,
                                              tag: $0.value(forKey: "drawingTag") as! String))
        })
        
        return drawingModels
    }
    
    func saveDrawing(delegate: AppDelegate, drawing: DrawingModel){
        
        let managedContext = delegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Drawing", in: managedContext)
        
        let call = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        call.setValue(drawing.tag, forKey: "drawingTag")
        call.setValue(drawing.dateCreated, forKey: "dateCreated")
        call.setValue(drawing.dateModified, forKey: "dateModified")
        call.setValue(drawing.drawingEntity, forKey: "drawingObject")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Couldn't save shit \(error), \(error.userInfo)")
        }
    }
    
    func deleteDrawing(delegate: AppDelegate, drawing: DrawingModel){
        let managedContext = delegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Drawing")
        fetchRequest.predicate = NSPredicate(format: "dateCreated == %@", drawing.dateCreated as NSDate)
        
        do {
            let availableDrawings = try managedContext.fetch(fetchRequest)
            availableDrawings.forEach({
                managedContext.delete($0)
             })
            
            try managedContext.save()
       } catch let error as NSError {
           print("Couldn't retrieve shit \(error), \(error.userInfo)")
       }
    }
    
    
    func editDrawing(delegate: AppDelegate, drawing: DrawingModel){
        var drawings : [NSManagedObject] = []
        
        let managedContext = delegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Drawing")
        //fetchRequest.predicate = NSPredicate(format: "dateCreated = '\(drawing.dateCreated as NSDate)'")
        fetchRequest.predicate = NSPredicate(format: "dateCreated == %@", drawing.dateCreated as NSDate)
        
        do {
            try drawings = managedContext.fetch(fetchRequest)
            if (drawings.count > 0){
                let drawingToEdit = drawings.first!
                drawingToEdit.setValue(drawing.tag, forKey: "drawingTag")
                drawingToEdit.setValue(drawing.drawingEntity, forKey: "drawingObject")
                drawingToEdit.setValue(drawing.dateModified, forKey: "dateModified")
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Couldn't save shit \(error), \(error.userInfo)")
                }
            }
        } catch let error as NSError {
            print("Couldn't retrieve shit \(error), \(error.userInfo)")
        }
    }
    
}

//
//  Pin.swift
//  Virtual Tourist
//
//  Created by AARON FARBER on 4/6/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Pin: NSManagedObject, MKAnnotation {

    static let entityName = "Pin"
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var pages: NSNumber?
    @NSManaged var photos: [Photo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(coordinate : CLLocationCoordinate2D, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName(Pin.entityName, inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.coordinate = coordinate
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set (newValue) {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
}

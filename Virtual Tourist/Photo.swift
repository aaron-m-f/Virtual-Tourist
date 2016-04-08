//
//  Photo.swift
//  Virtual Tourist
//
//  Created by AARON FARBER on 4/6/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Photo: NSManagedObject {

    static let entityName = "Photo"
    
    var downloadTask : NSURLSessionTask? = nil
    var uiImage : UIImage? = nil
    
    @NSManaged var imagePath: String?
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        let _ = image
    }
    
    init(imagePath : String, pin : Pin, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName(Photo.entityName, inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.imagePath = imagePath
        self.pin = pin
        
        getUIImage()
    }
    
    // MARK: Getting image
    
    var image : UIImage {
        get {
            
            if let uiImage = self.uiImage {
                
                // return image if it's  saved
                return uiImage
            } else if NSFileManager.defaultManager().fileExistsAtPath(imageFilePath) {
                
                // make image if data is saved
                uiImage = UIImage(contentsOfFile: imageFilePath)!
                return uiImage!
            } else if downloadTask != nil {
                
                // if download task already in progress, do nothing
                return UIImage()
            } else {
                
                // otherwise download the image and save it
                getUIImage()
                return UIImage()
            }
        }
    }
    
    private var imageFilePath : String {

        var escapeImagePath = imagePath!.stringByAddingPercentEncodingWithAllowedCharacters(.URLPathAllowedCharacterSet())
        escapeImagePath = imagePath!.stringByAddingPercentEncodingWithAllowedCharacters(.URLPasswordAllowedCharacterSet())

        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        return url!.URLByAppendingPathComponent(escapeImagePath!).path!
    }
    
    private func getUIImage() {
     
        let imageURL = NSURL(string: imagePath!)
        let request = NSURLRequest(URL: imageURL!)
        
        downloadTask = NetworkClient.dataTaskWithRequest(request) { data in
            self.uiImage = UIImage(data: data as! NSData)!
            self.saveImageData(data as! NSData)
        }
    }
    
    private func saveImageData(data : NSData) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            NSFileManager.defaultManager().createFileAtPath(self.imageFilePath, contents: data as NSData, attributes: nil)
            
            NSNotificationCenter.defaultCenter().postNotificationName(FlickerClient.Constants.Notification.ImageUpdated, object: nil)
        }
    }
    
    // MARK: Deletion
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        
        if downloadTask != nil {
            downloadTask?.cancel()
        }
                
        do {
            try NSFileManager.defaultManager().removeItemAtPath(self.imageFilePath)
        } catch let error as NSError {
            print(error.userInfo)
        }
    }
}

//
//  FlickerClient.swift
//  Virtual Tourist
//
//  Created by AARON FARBER on 4/6/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation
import CoreData

class FlickerClient {
    
    static let coreDataManager = CoreDataStackManager.sharedInstance()
    
    // MARK: Get saved gallery if it exists. Otherwise, download new gallery.

    static func getPhotosForPin(pin : Pin) -> [Photo] {
        
        let savedPhotos = getSavedPhotosForPin(pin)
        
        if savedPhotos.count > 0 {
            return savedPhotos
        }
        
        getNewImagesForPin(pin)
        return []
    }
    
    static func getSavedPhotosForPin(pin : Pin) -> [Photo] {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        
        do {
            let photos = try coreDataManager.managedObjectContext.executeFetchRequest(fetchRequest) as! [Photo]
            return photos
        } catch {
            NetworkClient.displayError("Error getting saved photos.  Please restart and try again.")
            return []
        }
    }
    
    // MARK: Reset photo gallery
    
    static func resetPhotosForPin(pin : Pin) -> [Photo] {
        
        let savedPhotos = getSavedPhotosForPin(pin)

        deletePhotos(savedPhotos)

        return getPhotosForPin(pin)
    }
    
    // MARK: Get list of images
    
    private static func getNewImagesForPin(pin: Pin) {
        
        let methodParameters = getMethodParameters(pin)
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        
        NetworkClient.jsonDataTaskWithRequest(request) { parsedResult in

            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String where stat == Constants.FlickrResponseValues.OKStatus else {
                NetworkClient.displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                NetworkClient.displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                NetworkClient.displayError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                pin.pages = min(totalPages, FlickerClient.Constants.Flickr.MaxPages)
                coreDataManager.saveContext()
            }
            
            self.setImageFiles(photosDictionary, toPin: pin)
        }
    }
    
    // MARK: Get Images
    
    private static func setImageFiles(photosDictionary : [String : AnyObject], toPin pin : Pin) {
        
        /* GUARD: Is the "photo" key in photosDictionary? */
        guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
            NetworkClient.displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            
            for photoDictionary in photosArray {
                
                if let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String {
                    
                    Photo(imagePath: imageURLString, pin: pin, context: coreDataManager.managedObjectContext)
                }
            }
            
            if pin.photos.count == 0 {
                
                NetworkClient.displayError("No Photos Found. Search Again.")
            } else {
            
                coreDataManager.saveContext()
                NSNotificationCenter.defaultCenter().postNotificationName(FlickerClient.Constants.Notification.GalleryUpdated, object: nil)
            }
        }
    }

    // MARK: Parameter Generators
    
    private static func getMethodParameters(pin : Pin) -> [String: String] {
        
        let latitude = pin.latitude
        let longitude = pin.longitude
        let page = Int(arc4random_uniform(UInt32(pin.pages as! Int)))
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude: latitude, longitude: longitude),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPage,
            Constants.FlickrParameterKeys.Page: String(page)
        ]
        
        return methodParameters
    }

    private static func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    private static func bboxString(latitude latitude : Double, longitude : Double) -> String {

        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    // MARK: Delete photos from gallery
    
    static func deletePhotos(photos : [Photo]) {
        
        for photo in photos {
            coreDataManager.deleteObject(photo)
        }
        coreDataManager.saveContext()
    }
}
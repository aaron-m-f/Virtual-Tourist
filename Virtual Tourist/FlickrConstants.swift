//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by AARON FARBER on 4/6/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation

extension FlickerClient {
    // MARK: - Constants
    
    struct Constants {
        
        // MARK: Flickr
        struct Flickr {
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
            
            static let SearchBBoxHalfWidth = 1.0
            static let SearchBBoxHalfHeight = 1.0
            static let SearchLatRange = (-90.0, 90.0)
            static let SearchLonRange = (-180.0, 180.0)
            
            static let MaxPages = 20
        }
        
        // MARK: Flickr Parameter Keys
        struct FlickrParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let Extras = "extras"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let SafeSearch = "safe_search"
            static let Text = "text"
            static let BoundingBox = "bbox"
            static let Page = "page"
            static let PerPage = "per_page"
        }
        
        // MARK: Flickr Parameter Values
        struct FlickrParameterValues {
            static let SearchMethod = "flickr.photos.search"
            static let APIKey = "7376f07dd718d317a592c2b6b0e4d2b8"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1" /* 1 means "yes" */
            static let MediumURL = "url_m"
            static let UseSafeSearch = "1"
            static let PerPage = "12"
        }
        
        // MARK: Flickr Response Keys
        struct FlickrResponseKeys {
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let MediumURL = "url_m"
            static let Pages = "pages"
        }
        
        // MARK: Flickr Response Values
        struct FlickrResponseValues {
            static let OKStatus = "ok"
        }
        
        // MARK: Notifications
        struct Notification {
            static let GalleryUpdated = "gallery updated"
            static let ImageUpdated = "image updated"
        }
    }
}
//
//  NetworkClient.swift
//  Virtual Tourist
//
//  Created by AARON FARBER on 4/6/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import Foundation

class NetworkClient {
    
    // MARK: Constants
    
    static let DownloadError = "error downloading"
    
    // MARK: Network Functions
    
    static func jsonDataTaskWithRequest (request : NSURLRequest, withCompletionHandler completionHandler : (result : AnyObject) -> Void) {
        
        NetworkClient.dataTaskWithRequest(request) { data in
            
            NetworkClient.parseJSON(data) { parsedResult in
                
                completionHandler(result: parsedResult)
            }
        }
    }
    
    static func dataTaskWithRequest(request : NSURLRequest, withCompletionHandler completionHandler : (result : AnyObject) -> Void) -> NSURLSessionTask {
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                self.displayError("There was an error with your request: \((error?.userInfo[NSLocalizedDescriptionKey])!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                self.displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                self.displayError("No data was returned by the request!")
                return
            }
            
            completionHandler(result: data)
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: JSON Function
    
    static func parseJSON(data : AnyObject, withCompletionHandler completionHandler : (result : AnyObject) -> Void) {
        
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .AllowFragments)
            completionHandler(result: parsedResult)
        } catch {
            NetworkClient.displayError("Could not parse the data as JSON: '\(data)'")
        }
    }
    
    // MARK: Error Functions
    
    static func displayError(error: String) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(NetworkClient.DownloadError, object: error)
        print(error)
    }
}
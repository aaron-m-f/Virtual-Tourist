//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by AARON FARBER on 4/5/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var editBarHeight: NSLayoutConstraint!
    
    let coreDataManager = CoreDataStackManager.sharedInstance()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var removingPins = false
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Radius = "region radius"
        static let Set = "initial location set"
    }
    
    // MARK : Loading
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
        
        getInitialMapLocation()
        getSavedPins()
    }
    
    // MARK: Starting View
    
    func getInitialMapLocation() {

        if userDefaults.boolForKey(Keys.Set) {
            
            let latitude = userDefaults.doubleForKey(Keys.Latitude)
            let longitude = userDefaults.doubleForKey(Keys.Longitude)
            
            let initialLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            mapView.setCenterCoordinate(initialLocation, animated: false)
        }
    }
    
    func getSavedPins() {
        
        let pins = coreDataManager.getSavedObjects(Pin.entityName) as! [Pin]
        self.mapView.addAnnotations(pins)
    }
    
    // MARK: Pin Dropping
    
    @IBAction func longPressGestured(sender: UILongPressGestureRecognizer) {
        
        if (sender.state == UIGestureRecognizerState.Began) {
            
            let location = sender.locationInView(mapView)
            let coordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
            
            addPin(coordinate)
        }
    }
    
    func addPin(coordinate : CLLocationCoordinate2D) {
        
        let pin = Pin(coordinate: coordinate, context: coreDataManager.managedObjectContext)
        
        self.mapView.addAnnotation(pin)
        coreDataManager.saveContext()
    }
    
    // MARK: Save Map Location
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

        saveMapCoordinates()
    }

    func saveMapCoordinates() {
        
        userDefaults.setDouble(mapView.centerCoordinate.latitude, forKey: Keys.Latitude)
        userDefaults.setDouble(mapView.centerCoordinate.longitude, forKey: Keys.Longitude)

        userDefaults.setBool(true, forKey: Keys.Set)
    }
    
    // MARK: Edit Button
    
    @IBAction func editButtonTouched(sender: UIBarButtonItem) {

        if mapViewBottomConstraint.constant == 0 {
            
            sender.title = "Done"
            mapViewBottomConstraint.constant = editBarHeight.constant
            removingPins = true
        } else {
            
            sender.title = "Edit"
            mapViewBottomConstraint.constant = 0
            removingPins = false
        }
        
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = true
            pinView!.canShowCallout = false
        } else {
            
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let pin = view.annotation as! Pin
        
        mapView.deselectAnnotation(pin, animated: false)

        if removingPins {
            
            coreDataManager.deleteObject(pin)
            coreDataManager.saveContext()
            
            mapView.removeAnnotation(pin)
        } else {
            
            performSegueWithIdentifier("PHOTO_ALBUM_SEGUE", sender: pin)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        super.prepareForSegue(segue, sender: sender)
        
        let destinationController = segue.destinationViewController as! PhotoAlbumViewController
        destinationController.pin = sender as! Pin        
    }
}


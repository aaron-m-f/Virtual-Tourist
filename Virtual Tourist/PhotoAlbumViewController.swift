//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by AARON FARBER on 4/6/16.
//  Copyright © 2016 Aaron Farber. All rights reserved.
//

import UIKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pin : Pin!
    var photos = [Photo]()
    var selectedPhotos = Set<Photo>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        automaticallyAdjustsScrollViewInsets = false
        
        fixFlowLayout()
        
        photos = FlickerClient.getPhotosForPin(pin)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadGallery), name: FlickerClient.Constants.Notification.GalleryUpdated, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(collectionView, selector: #selector(collectionView.reloadData), name: FlickerClient.Constants.Notification.ImageUpdated, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showErrorAlert), name: NetworkClient.DownloadError, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: FlickerClient.Constants.Notification.GalleryUpdated, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(collectionView, name: FlickerClient.Constants.Notification.ImageUpdated, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NetworkClient.DownloadError, object: nil)
    }
    
    // MARK: - Data Loading
    
    func reloadGallery() {
        
        photos = FlickerClient.getPhotosForPin(pin)
        collectionView.reloadData()
    }
    
    func checkIfAllImagesLoaded() {
                
        button.enabled = false
        collectionView.allowsSelection = false
        collectionView.allowsMultipleSelection = false
        
        if photos.count == 0 {
            
            activityIndicator.startAnimating()
            return
        }
        
        activityIndicator.stopAnimating()
        
        for photo in photos {
            if photo.uiImage == nil {
                return
            }
        }
        
        button.enabled = true
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
    }
    
    // MARK: Flow Layout
    
    func fixFlowLayout() {
        
        let space: CGFloat = 2.0
        var dimension = collectionView.bounds.size.width
        
        if collectionView.bounds.size.width < collectionView.bounds.size.height {
            dimension = floor(dimension / 2)
        } else {
            dimension = floor(dimension / 3)
        }
        
        dimension -= 2 * space
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ context in self.fixFlowLayout() }, completion: { context in self.fixFlowLayout() })
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        checkIfAllImagesLoaded()
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTO_CELL", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        cell.photo = photos[indexPath.row]
        cell.photoImageView.image = photos[indexPath.row].image
        
        if cell.selected {
            
            cell.selectedImageView.alpha = 0.75
        } else {
            
            cell.selectedImageView.alpha = 0.0
        }
        
        fixFlowLayout()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        cell.selectedImageView.alpha = 0.75
     
        selectedPhotos.insert(cell.photo)
        updateButton()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {

        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        cell.selectedImageView.alpha = 0.0
        
        selectedPhotos.remove(cell.photo)
        updateButton()
    }
    
    // MARK: - Button
    
    func updateButton() {
        
        if selectedPhotos.count > 0 {
            
            button.backgroundColor = UIColor.redColor()
            button.setTitle("Delete Photos", forState: UIControlState.Normal)
            button.tintColor = UIColor.whiteColor()
        } else {
            
            button.backgroundColor = UIColor.groupTableViewBackgroundColor()
            button.setTitle("Load New Collection", forState: UIControlState.Normal)
            button.tintColor = view.tintColor
        }
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        
        if selectedPhotos.count > 0 {
            
            FlickerClient.deletePhotos(Array(selectedPhotos))
            selectedPhotos.removeAll()

            reloadGallery()
            updateButton()
        } else {
            
            // otherwise, get entirely new collection
            photos = []
            button.enabled = false
            FlickerClient.resetPhotosForPin(pin)
        }
        
        collectionView.reloadData()
    }
    
    // MARK: - Error Alert
    
    func showErrorAlert(notification : NSNotification) {
        
        if let message = notification.object as? String {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                
                self.presentViewController(alertView, animated: true) {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                }
            }
        }
    }
}

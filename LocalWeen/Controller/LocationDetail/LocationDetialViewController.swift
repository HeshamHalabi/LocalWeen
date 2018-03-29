//
//  LocationDetialViewController.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/2/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.


import Cosmos
import UIKit
import GoogleMaps
import CoreLocation
import SwiftyBeaver

class LocationDetialViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let picker:UIImagePickerController? = UIImagePickerController()
    var coord:CLLocationCoordinate2D? = CLLocationCoordinate2D()
    let dbHandler = DBHandler()
    let storageHandler = StorageHandler()
    let locationManager = CLLocationManager()
    var currentImage = 0
    var existingPhotosList = [String]()
    
    //Outlets
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var userChosenPhotoFromGalleryOrCamera: UIImageView!
    @IBOutlet weak var avLabel: UILabel!
    @IBOutlet weak var existingPhotos: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        reverseGeocodeCoordinate(coord!)
        averageRating(coordinate: coord!)
        
        existingPhotos.isHidden = true
        
        //MARK: Get list of location photos from DB
        
        dbHandler.getFor(coordinateIn: coord!, what: "filename") { (filenames) in
           // let sv = UIViewController.displaySpinner(onView: self.view)
            if filenames.isEmpty {
                log.verbose("File name array is empty")
            } else {
                if let array = filenames as? [String] {
                    self.existingPhotosList = array
                }//if let array
            }//if filenames.isEmpty
           // UIViewController.removeSpinner(spinner: sv)
        }//dbHandler
        
        
        guard let firstPhoto = existingPhotosList.first else {
            log.debug("ExistingPhotosList does not have any first image - which could be fine since we may not have any")
            return
        }
        
        storageHandler.downLoad(filename: firstPhoto, imageView: existingPhotos)
    
        
        //MARK: Cosmos Setup
        if cosmosView.rating <= 0  {
            saveButton.isEnabled = false
        }//if
        cosmosView.rating = 0
        cosmosView.didFinishTouchingCosmos = didFinishTouchingCosmos
        cosmosView.didTouchCosmos = didTouchCosmos
        
        
        //MARK: Image Picker Setup
        picker?.delegate = self
        userChosenPhotoFromGalleryOrCamera.isHidden = true
        
        //MARK: Swipe setup

        log.debug("Set existing photo to placeholder")
        existingPhotos.image = String.kPhotoPlaceholder
      
    
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(gestureRecognizer:)))
        leftSwipeGesture.direction = UISwipeGestureRecognizerDirection.left
        existingPhotos.isUserInteractionEnabled = true
        existingPhotos.addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(imageSwiped(gestureRecognizer:)))
        rightSwipeGesture.direction = UISwipeGestureRecognizerDirection.right
        existingPhotos.addGestureRecognizer(rightSwipeGesture)
      
        
    }//viewDidLoad
    
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }//let address
            self.addressLabel.text = lines.joined(separator: " , ")
        }//geocoder.reverseGeocodeCoordinate
    }//reverseGeocodeCoordinate
    
    
    @IBAction func saveButton(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: String.kAgreementTitle, message: String.kAgreementDetails, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Agree - Save", style: .default, handler: { (action:UIAlertAction) in
           //Save the data
            guard let coordinate = self.coord else {
                log.error(String.errorGet + "self.coord")
                return
            }//guard
            
            // store location rating and possibly image path if an image was chosen
            if self.userChosenPhotoFromGalleryOrCamera.image != nil {
                let imageName:String = self.storageHandler.upLoad(imageToUpload: self.userChosenPhotoFromGalleryOrCamera.image!)
                self.dbHandler.addLocation(coordinate: coordinate, rating: self.cosmosView.rating, imageName: imageName)
            } else {
                //don't upload an image, just save the location rating and coord
                self.dbHandler.addLocation(coordinate: coordinate, rating: self.cosmosView.rating, imageName: "")
            }//else
            self.performSegue(withIdentifier: String.kSegueBACKToMap, sender: self.saveButton)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Disagree - Cancel", style: .cancel, handler: { (action) in
             self.performSegue(withIdentifier: String.kSegueBACKToMap, sender: self.saveButton)
        }))
        
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }//addButton
    
    
    @IBAction func photoButton(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Source", message: String.kPhotoSourceChoice, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: String.kCameraText, style: .default, handler: { (action:UIAlertAction) in
            self.openCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: String.kPhotoLibraryText, style: .default, handler: { (action:UIAlertAction) in
            self.openGallary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }//photoButton
    
    
    
}//LocationDetailViewController

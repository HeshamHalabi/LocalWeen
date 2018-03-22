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

    
    //Outlets
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var userChosenPhotoFromGalleryOrCamera: UIImageView!
    
    @IBOutlet weak var avLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cosmosView.rating = 0
        reverseGeocodeCoordinate(coord!)
        getLocationPhotos(coordinate: coord!)
        
        if cosmosView.rating <= 0  {
            saveButton.isEnabled = false
        }//if
        cosmosView.didFinishTouchingCosmos = didFinishTouchingCosmos
        cosmosView.didTouchCosmos = didTouchCosmos
        picker?.delegate = self
        userChosenPhotoFromGalleryOrCamera.isHidden = true
        averageRating(coordinate: coord!)
        
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
        let actionSheet = UIAlertController(title: "Save Agreement", message: "You certify that you are not submitting a location for any illegal or unethical reason.  You agree to the application Terms of Service", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Agree - Save", style: .default, handler: { (action:UIAlertAction) in
           //Save the data
            guard let coordinate = self.coord else {
                log.error("Can't get coordinate")
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
            self.performSegue(withIdentifier: "backToMap", sender: self.saveButton)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Disagree - Cancel", style: .cancel, handler: { (action) in
             self.performSegue(withIdentifier: "backToMap", sender: self.saveButton)
        }))
        
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }//addButton
    
    
    @IBAction func photoButton(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            self.openCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { (action:UIAlertAction) in
            self.openGallary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }//photoButton
    
    //MARK: Get Location Photos
    func getLocationPhotos(coordinate:CLLocationCoordinate2D){
        dbHandler.getFor(coordinateIn: coordinate, what: "fileNames") { (fileNames) in
            for file in fileNames{
                log.verbose("\(String(describing: file))")
            }//for
        }//dbHandler
    }//getLocationPhotos
    
}//LocationDetailViewController

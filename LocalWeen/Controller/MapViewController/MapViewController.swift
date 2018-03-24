//
//  MapViewController.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/2/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase
import GoogleSignIn
import GooglePlaces
import SwiftyBeaver
import MapKit
import FirebaseAuthUI
import FBSDKLoginKit

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    //Map Support
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    let dbHandler = DBHandler()
    var tappedMarkerLocation = CLLocationCoordinate2D()
    var singleSearchResult = CLLocationCoordinate2D()
    let userMarker = GMSMarker()
    var stopCamera:Bool = false
    
    //Constants
    let zoom:Float = 15
    let locationOfInterestImage = "hhouseicon"
    let userMarkerImage = "witchicon"
    let questionMarker = "questionMapMaker"
    
    //Search Bar Support
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    let resultMarker:GMSMarker = GMSMarker()
  
    
    //Directions Support
    @IBOutlet weak var directionsButton: UIButton!
    
    
    /*
     
     There are three different sets of data to send in segue
     1.  User simply sees self icon on map and no marker is in DB, so they want to add one
         Therefore segueWhat = dataToSegue.userLocation
     
     2.  User has done a search and found a location that has no marker in DB, so they want to add.  Therefore segueWhat = dataToSegue.searchResult
     
     3.  User has tapped on a marker.  The marker could be either the marker showing the user location or the marker could be a location of interest.  In either case, the data will be the location of the marker.  Therefore segueWhat = dataToSegue.tappedMarker
    
    */
    enum dataToSegue {
        case userLocation, tappedMarker, searchResult
    }
    
    var segueWhat:dataToSegue?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Directions button is disabled until user taps on maker
        directionsButton.isEnabled = false
        
        //hide the back button of navigation view controller, as it is not needed here
        self.navigationItem.hidesBackButton = true
        self.setupSearchBar()
        self.startUpLocationManager()
    
        mapView.settings.myLocationButton = true
        
        //Get all stored locations and place marker
        dbHandler.getFor(coordinateIn: nil, what: "coordinate") { (arCoordinate) in
            for coord in arCoordinate{
                let lat = (coord as! CLLocationCoordinate2D).latitude
                let long = (coord as! CLLocationCoordinate2D).longitude
                self.placeMarker(latitude: lat, longitude: long, imageName: self.locationOfInterestImage)
                log.verbose("\(String(describing: lat)) , \(String(describing: long)) ")
            }//for
            
        }//dbHandler

        
    }//ViewDidLoad
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
      
        switch segueWhat {
        case .userLocation?:
            if let destination = segue.destination as? LocationDetialViewController {
                destination.coord = self.locationManager.location?.coordinate
                log.verbose("\(String(describing:destination.coord  ))")
            } else { return }
        case .tappedMarker?:
            if let destination = segue.destination as? LocationDetialViewController {
                destination.coord = self.tappedMarkerLocation
                log.verbose("\(String(describing:destination.coord  ))")
            } else {return}
        case .searchResult?:
            if let destination = segue.destination as? LocationDetialViewController {
                destination.coord = singleSearchResult
                log.verbose("\(String(describing:destination.coord  ))")
              
            } else {return}
        default:
            log.verbose("default")
        }
    }//prepare

    
    //MARK: Pinch Management
    @IBAction func didPinch(_ sender: UIPinchGestureRecognizer) {
        log.verbose("stopCamera = true")
        stopCamera = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: Sign Out
    
    @IBAction func didTapSignOut(_ sender: UIButton) {
        log.verbose("didTapSignOut stopCamera = false")
        stopCamera = true
        log.verbose("didTapSignOut - stopUpdatingLocation()")
        locationManager.stopUpdatingLocation()
        log.verbose("GIDSignIn.sharedInstance().signOut()")
        GIDSignIn.sharedInstance().signOut()
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        if authUI != nil {
            do {
                try authUI?.signOut()
            } catch {
                
                log.error("ERROR on sign out", error.localizedDescription)
                
                /*Possible error codes: - FIRAuthErrorCodeKeychainError Indicates an error occurred when accessing the keychain. The NSLocalizedFailureReasonErrorKey field in the NSError.userInfo dictionary will contain more information about the error encountered. */
            }
            
        } else {
            log.warning("AuthUI is nil, can't log out???")
        }
       
        performSegue(withIdentifier: "backToWelcome", sender: self)
    }
    
    //MARK: Did Tap Marker
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        log.info("Setting stopCamera true when marker tapped so camera is at marker and not following user")
        stopCamera = true
        locationManager.stopUpdatingLocation()
        directionsButton.isEnabled = true
        segueWhat = dataToSegue.tappedMarker
        self.tappedMarkerLocation = marker.position
        performSegue(withIdentifier: "toDetail", sender: self)
        return false
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture == true {
            stopCamera = true
        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        stopCamera = false
        return true
    }
    
    @IBAction func didTapDirections(_ sender: UIButton) {
        log.info("Setting stopCamera = true user asked for directions, so stop following user on map")
        stopCamera = true
        directionsButton.isEnabled = false
        guard let from = locationManager.location?.coordinate else {
            log.warning("Could not get user's current location for driving directions")
            return
        }
        
        let to = self.tappedMarkerLocation
        
        log.info("Directions from \(String(describing: from)) , to \(String(describing: tappedMarkerLocation))")
        let url = "http://maps.apple.com/maps?saddr=\(from.latitude),\(from.longitude)&daddr=\(to.latitude),\(to.longitude)"
        //UIApplication.shared.openURL(URL(string:url)!)
        let regionDistance:CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegionMakeWithDistance(tappedMarkerLocation, regionDistance, regionDistance)
        var options = [String : Any]()
            options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        UIApplication.shared.open(URL(string:url)!, options: options) { (finished) in
            if finished {
                log.info("Setting stopCamera to false because we are done with the external map and perhaps we need to follow the user with the camera")
                self.stopCamera = true
                log.info("Done opening Maps = \(String(describing: finished))")
            }
        }
    }
    
    
    
}//MapViewController




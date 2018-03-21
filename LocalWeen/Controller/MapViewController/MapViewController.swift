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
import FBSDKLoginKit
import SwiftyBeaver
import MapKit

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
    var searchCoordinates:CLLocationCoordinate2D = CLLocationCoordinate2D()
    
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
            }//for
            
        }//dbHandler
        
        //Pinch Recognizer
        
        
    }//ViewDidLoad
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        //WHAT TO DO HERE, NEED ANSWER TO ENUM QUESTION
        switch segueWhat {
        case .userLocation?:
            if let destination = segue.destination as? LocationDetialViewController {
                destination.coord = self.locationManager.location?.coordinate
            } else { return }
        case .tappedMarker?:
            if let destination = segue.destination as? LocationDetialViewController {
                destination.coord = self.tappedMarkerLocation
            } else {return}
        case .searchResult?:
            if let destination = segue.destination as? LocationDetialViewController {
                destination.coord = singleSearchResult
                print("blah")
            } else {return}
        default:
            print("goodbye")
        }
    }//prepare

    
    //MARK: Pinch Management
    @IBAction func didPinch(_ sender: UIPinchGestureRecognizer) {
        SwiftyBeaver.verbose("didPinch(_ sender: UIPinchGestureRecognizer), stopCamera = true")
        stopCamera = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: Sign Out
    
    @IBAction func didTapSignOut(_ sender: UIButton) {
        SwiftyBeaver.verbose("didTapSignOut stopCamera = false")
        stopCamera = true
        SwiftyBeaver.verbose("didTapSignOut - stopUpdatingLocation()")
        locationManager.stopUpdatingLocation()
        SwiftyBeaver.verbose("GIDSignIn.sharedInstance().signOut()")
        GIDSignIn.sharedInstance().signOut()
        SwiftyBeaver.verbose("FBSDKLoginManager().logOut()")
        FBSDKLoginManager().logOut()
    }
    
    //MARK: Did Tap Marker
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        SwiftyBeaver.info("Setting stopCamera true when marker tapped so camera is at marker and not following user")
        stopCamera = true
        SwiftyBeaver.verbose("locationManager.stopUpdatingLocation()")
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
        SwiftyBeaver.info("Setting stopCamera = true user asked for directions, so stop following user on map")
        stopCamera = true
        directionsButton.isEnabled = false
        guard let from = locationManager.location?.coordinate else {
            SwiftyBeaver.warning("didTapDirections: could not get user's current location for driving directions")
            return
        }
        
        let to = self.tappedMarkerLocation
        
        SwiftyBeaver.info("Directions from \(String(describing: from)) , to \(String(describing: tappedMarkerLocation))")
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
                SwiftyBeaver.info("Setting stopCamera to false because we are done with the external map and perhaps we need to follow the user with the camera")
                self.stopCamera = true
                SwiftyBeaver.info("Done opening Maps = \(String(describing: finished))")
            }
        }
    }
    
    
    
}//MapViewController




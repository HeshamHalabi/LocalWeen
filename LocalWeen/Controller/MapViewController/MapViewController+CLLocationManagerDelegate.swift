//
//  MapViewController+CLLocationManagerDelegate.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/15/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//


import GoogleMaps
import SwiftyBeaver

extension MapViewController {
    func startUpLocationManager(){
        SwiftyBeaver.verbose("startUpLocationManager()")
        //Location Manager and Map View Delegate
        SwiftyBeaver.verbose("locationManager.requestWhenInUseAuthorization()")
        self.locationManager.requestWhenInUseAuthorization()
        SwiftyBeaver.verbose("locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation")
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.startUpdatingLocation()
        self.locationManager.activityType = .automotiveNavigation
        self.locationManager.pausesLocationUpdatesAutomatically = true
        self.locationManager.delegate = self
        self.mapView.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            SwiftyBeaver.info("authorizedWhenInUse = \(String(describing: status ))")
            self.mapView.settings.myLocationButton = true
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            SwiftyBeaver.warning("locationManager didUpdateLocations could not get user location")
            return
        }
        
        SwiftyBeaver.info("locationManager didUpdateLocation to \(String(describing: location))")

        if stopCamera {
            SwiftyBeaver.verbose("stopCamera = \(String(describing: stopCamera))")
            SwiftyBeaver.info("The user pinched on map, so camera is not going to change positions.  Place the marker")
            print("Stop camera")
            self.placeMarker(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, imageName: userMarkerImage)
        } else {
            SwiftyBeaver.info("User did not pinch on map, so move the camera and place marker")
            self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            self.placeMarker(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, imageName: userMarkerImage)

        }
        
        segueWhat = dataToSegue.userLocation
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        SwiftyBeaver.info("Location Manager has PAUSED location updates to save battery")
        SwiftyBeaver.info("Lowering desiredAccuracy to kCLLocationAccuracyHundredMeters")
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager){
        SwiftyBeaver.info("Location Manager has RESUMED location updates to save battery")
         self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
}

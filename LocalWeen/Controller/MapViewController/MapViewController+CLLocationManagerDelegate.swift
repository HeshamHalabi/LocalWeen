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
        //Location Manager and Map View Delegate
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.startUpdatingLocation()
        self.locationManager.activityType = .automotiveNavigation
        self.locationManager.pausesLocationUpdatesAutomatically = true
        self.locationManager.delegate = self
        self.mapView.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            log.verbose("authorizedWhenInUse = \(String(describing: status ))")
            self.mapView.settings.myLocationButton = true
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            log.warning(String.warningGet + "user location")
            return
        }
        
        log.verbose("\(String(describing: location))")

        if stopCamera {
            log.verbose("stopCamera = \(String(describing: stopCamera))")
            self.placeMarker(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, imageName: userMarkerImage)
        } else {
            log.verbose("User did not pinch on map, so move the camera and place marker")
            self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            self.placeMarker(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, imageName: userMarkerImage)

        }
        
        segueWhat = dataToSegue.userLocation
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        log.verbose("Location Manager has PAUSED location updates to save battery")
        log.verbose("Lowering desiredAccuracy to kCLLocationAccuracyHundredMeters")
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager){
        log.verbose("Location Manager has RESUMED location updates to save battery")
         self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
}

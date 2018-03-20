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
        self.mapView.isMyLocationEnabled = true
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
        locationManager.stopUpdatingLocation()
        guard let location = locations.first else {
            SwiftyBeaver.warning("Could not get user location")
            return
        }
        
        SwiftyBeaver.info("didUpdateLocation to \(String(describing: location))")
        self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
        self.placeMarker(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, imageName: userMarkerImage)
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

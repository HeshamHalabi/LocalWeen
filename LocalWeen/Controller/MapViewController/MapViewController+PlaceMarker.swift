//
//  MapViewController+PlaceMarker.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/15/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import SwiftyBeaver
import GoogleMaps


extension MapViewController {
    func placeMarker(latitude: Double, longitude:Double, imageName: String){
        
        if imageName == userMarkerImage {
            log.verbose("userMarkerImage: \(String(describing: userMarkerImage))")
            
            userMarker.map = self.mapView
            
            log.verbose("userMarker.map = \(String(describing: userMarker.map))")
            userMarker.icon = UIImage(named: imageName)
            log.verbose("userMarker.image = \(String(describing: imageName))")
            userMarker.position = CLLocationCoordinate2DMake(latitude, longitude)
            log.verbose("userMarker.position = \(String(describing: latitude)) , \(String(describing: longitude)) ")
            
        } else {
            
            let myMarker = GMSMarker()
            myMarker.map = self.mapView
            myMarker.icon = UIImage(named: imageName)
            myMarker.position = CLLocationCoordinate2DMake(latitude, longitude)
            log.verbose(String.complete +  "marker \(String(describing: imageName)) \(String(describing: myMarker.position ))")

        }
    }//placeMarker
}

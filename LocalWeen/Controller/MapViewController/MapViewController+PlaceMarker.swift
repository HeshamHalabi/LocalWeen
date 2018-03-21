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
            SwiftyBeaver.info("!!!!!!! Placing userMarker !!!!!!!")
            SwiftyBeaver.verbose("placeMarker: imageName == userMarkerImage: \(String(describing: userMarkerImage))")
            SwiftyBeaver.info("Placing user icon")
            
            userMarker.map = self.mapView
            
            SwiftyBeaver.info("userMarker.map = \(String(describing: userMarker.map))")
            userMarker.icon = UIImage(named: imageName)
            SwiftyBeaver.info("userMarker.image = \(String(describing: imageName))")
            userMarker.position = CLLocationCoordinate2DMake(latitude, longitude)
            SwiftyBeaver.info("userMarker.position = \(String(describing: latitude)) , \(String(describing: longitude)) ")
            
            
        } else {
            SwiftyBeaver.info("Placing Haunted House")
            let myMarker = GMSMarker()
            myMarker.map = self.mapView
            myMarker.icon = UIImage(named: imageName)
            myMarker.position = CLLocationCoordinate2DMake(latitude, longitude)
        }
    }//placeMarker
}

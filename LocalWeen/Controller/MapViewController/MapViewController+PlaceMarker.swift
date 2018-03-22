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
            SwiftyBeaver.verbose("placeMarker: imageName == userMarkerImage: \(String(describing: userMarkerImage))")
            
            userMarker.map = self.mapView
            
            SwiftyBeaver.verbose("userMarker.map = \(String(describing: userMarker.map))")
            userMarker.icon = UIImage(named: imageName)
            SwiftyBeaver.verbose("userMarker.image = \(String(describing: imageName))")
            userMarker.position = CLLocationCoordinate2DMake(latitude, longitude)
            SwiftyBeaver.verbose("userMarker.position = \(String(describing: latitude)) , \(String(describing: longitude)) ")
            
        } else {
            let myMarker = GMSMarker()
            myMarker.map = self.mapView
            myMarker.icon = UIImage(named: imageName)
            myMarker.position = CLLocationCoordinate2DMake(latitude, longitude)
            SwiftyBeaver.verbose("Placing Haunted House \(String(describing: myMarker.position ))")

        }
    }//placeMarker
}

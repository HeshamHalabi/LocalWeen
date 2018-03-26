//
//  LocationDetialViewController+Ratings.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/12/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import Cosmos
import UIKit
import CoreLocation

extension LocationDetialViewController {
    
    func didTouchCosmos(_ rating: Double){
        saveButton.isEnabled = true
    }//didTouchCosmos
    
    func didFinishTouchingCosmos(_ rating: Double){
        saveButton.isEnabled = true
    }//didFinishTouchingCosmos
    
    
    func averageRating(coordinate:CLLocationCoordinate2D){
        var totalRating:Double = 0
        dbHandler.getFor(coordinateIn: coordinate, what: "ratings") { (ratings) in
            for rating in ratings {
                totalRating += rating as! Double
            }//for ratings
            
            guard totalRating >= 1.0 else { return}
            var av:Double = 0
            av = (Double(totalRating))/(Double(ratings.count))
            if av < 1 {
               self.avLabel.text = ""
            }
            let avRatingStr = String(format: "%.2f", ceil(av * 100)/100)
            self.avLabel.text = avRatingStr + " average of " + String(ratings.count) + " ratings"
            
        }//dbHandler
    }//averageRating
}

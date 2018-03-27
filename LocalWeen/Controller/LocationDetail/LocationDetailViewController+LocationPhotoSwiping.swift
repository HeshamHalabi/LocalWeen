//
//  LocationDetailViewController+LocationPhotoSwiping.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/26/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
import MapKit
import SwiftyBeaver

extension LocationDetialViewController {
    
    @objc func imageSwiped(gestureRecognizer: UIGestureRecognizer) {
        
        if let swipeGesture = gestureRecognizer as? UISwipeGestureRecognizer{
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left :
                log.debug("Left Swipe")
                if currentImage == photos.count - 1 && photos.count >= 0{
                    currentImage = 0
                    log.debug("Set current image to 0")
                    
                }else{
                    currentImage += 1
                    log.debug("Current image = \(String(describing: currentImage))")
                    
                }//currentImage
                
                let image = photos[currentImage]
                
                self.existingPhotos.image = image
                log.debug("Image \(String(describing: image))")
                
            case UISwipeGestureRecognizerDirection.right:
                log.debug("Right Swipe")
                if currentImage == 0 && photos.count >= 1 {
                    currentImage = photos.count - 1
                    log.debug("Set currentImage to photos.count - 1 = \(String(describing: photos.count - 1))"  )
                } else {
                    currentImage -= 1
                    log.debug("Current image = \(String(describing: currentImage))")
                    
                }//curentImage
    
                log.debug("currentImage \(String(describing: currentImage ))")
                
                let image = photos[currentImage]
                self.existingPhotos.image = image
                log.debug("Image \(String(describing: image))")
                
            default:
                break
            }//switch
        }//swipeGesture
    }//func
}//extension

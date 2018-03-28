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
                if currentImage == existingPhotosList.count - 1 && existingPhotosList.count >= 0{
                    currentImage = 0
                    log.debug("Set current image to 0")
                    
                }else{
                    currentImage += 1
                    log.debug("Current image = \(String(describing: currentImage))")
                    
                }//currentImage
                
                if currentImage >= 0 {
                    let imageToDownload = existingPhotosList[currentImage]
                    storageHandler.downLoad(filename: imageToDownload , imageView: existingPhotos)
                }
            
                
            case UISwipeGestureRecognizerDirection.right:
                log.debug("Right Swipe")
                if currentImage == 0 && existingPhotosList.count >= 1 {
                    currentImage = existingPhotosList.count - 1
                    log.debug("Set currentImage to photos.count - 1 = \(String(describing: existingPhotosList.count - 1))"  )
                } else {
                    currentImage -= 1
                    log.debug("Current image = \(String(describing: currentImage))")
                    
                }//curentImage
    
                log.debug("currentImage \(String(describing: currentImage ))")
                
                let imageToDownload = existingPhotosList[currentImage]
                storageHandler.downLoad(filename: imageToDownload , imageView: existingPhotos)
                
            default:
                break
            }//switch
        }//swipeGesture
    }//func
}//extension

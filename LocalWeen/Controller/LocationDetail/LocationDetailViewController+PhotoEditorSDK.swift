//
//  LocationDetailViewController+PhotoEditorSDK.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/27/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
import PhotoEditorSDK
import SwiftyBeaver

extension LocationDetialViewController: PhotoEditViewControllerDelegate {
    
     func buildConfiguration() -> Configuration {
        let configuration = Configuration() { builder in
            // Configure camera
            builder.configureCameraViewController() { options in
                // Just enable Photos
                options.allowedRecordingModes = [.photo]
            }
        }
        
        return configuration
    }
    
     func createPhotoEditViewController(with photo: Photo) -> PhotoEditViewController {
        let configuration = buildConfiguration()
        var menuItems = PhotoEditMenuItem.defaultItems
        menuItems.removeLast() // Remove last menu item ('Magic')
        
        
        // Create a photo edit view controller
        let photoEditViewController = PhotoEditViewController(photoAsset: photo, configuration: configuration, menuItems: menuItems)
        photoEditViewController.delegate = self
        
        return photoEditViewController
    }
    
    
     func presentPhotoEditViewController() {
        
        let photo = Photo.init(image: userChosenPhotoFromGalleryOrCamera.image!)
        present(createPhotoEditViewController(with: photo), animated: true )
    }

    
    
    
    
    func photoEditViewController(_ photoEditViewController: PhotoEditViewController, didSave image: UIImage, and data: Data) {
        /*
         t provides the resulting image as an UIImage and a Data object. Please note that the EXIF data of the input image is only fully contained within the Data object. Please refer to the next section for more information about EXIF handling.
 */
    }
    
    func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
        log.error(String.errorGet + "photo")
    }
    
    func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
        log.verbose("Canceled Editing")
    }
    
    
    func photoEditor(){
        let cameraViewController = CameraViewController()
        present(cameraViewController, animated: true, completion: nil)
    }
}


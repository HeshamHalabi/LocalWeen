//
//  LocationDetailViewController+PhotoGallery.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/12/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
extension LocationDetialViewController {

    func openGallary()
    {
        
        picker!.allowsEditing = false
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker!, animated: true, completion: nil)
    }//openGallary

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        userChosenPhotoFromGalleryOrCamera.image = chosenImage
        
        log.debug("Chose a photo")
        
        picker.dismiss(animated: true, completion: {
            log.debug("Dismiss the picker controller and present Photo Edit")
            self.presentPhotoEditViewController()
        })
        log.debug("Stop hiding the user chosen image")
        userChosenPhotoFromGalleryOrCamera.isHidden = false
        
    }//imagePickerController
}


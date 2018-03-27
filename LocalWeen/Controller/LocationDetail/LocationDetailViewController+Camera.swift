//
//  LocationDetailViewController+Camera.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/12/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit

extension LocationDetialViewController {
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker!.allowsEditing = false
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker!.cameraCaptureMode = .photo
            present(picker!, animated: true, completion: nil)
        } else {
            
            let alert = UIAlertController(title: String.errorGeneral, message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }//else
    }//openCamera
    
    
}

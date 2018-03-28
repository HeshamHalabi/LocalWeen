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
import MobileCoreServices
import AVFoundation
import Photos


extension LocationDetialViewController: PhotoEditViewControllerDelegate {
    
     func buildConfiguration() -> Configuration {
        
        let configuration = Configuration() { builder in
            // Configure camera
            builder.configureCameraViewController() { options in
                /*******************************************/
                options.includeUserLocation = true // See what this does
                  /*******************************************/
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
 
        if userChosenPhotoFromGalleryOrCamera.image != nil {
            let photo = Photo.init(image: userChosenPhotoFromGalleryOrCamera.image!)
            present(createPhotoEditViewController(with: photo), animated: true )
        } else {
            log.warning(String.warningGeneral + "userChosenPhotoFromGalleryOrCamera.image is nil")
        }
    }

    
    func photoEditViewController(_ photoEditViewController: PhotoEditViewController, didSave image: UIImage, and data: Data) {
        log.debug("Save image to photo album")
        UIImageWriteToSavedPhotosAlbum(image, didSaveImage(photoEditViewController: photoEditViewController), nil, nil)
    }
    
    func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
        log.error(String.errorGet + "photo")
    }
    
    func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
        log.verbose("Canceled Editing")
    }
    
    
    // MARK: - UIImageWriteToSavedPhotosAlbum Completion Target
    func didSaveImage(photoEditViewController: PhotoEditViewController){
        log.debug("Save Alert")
        let alert =  UIAlertController(title: "Saved", message: "Saved to Camera Roll", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (alertAction) in
            // Return any edited content to the host app.
            self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
        }))
        photoEditViewController.present(alert, animated: true)
    }
    
    func photoEditor(){
        let cameraViewController = CameraViewController()
        present(cameraViewController, animated: true, completion: nil)
    }
    
    func doesNSExtentionItemHavePhoto(){
        
        if self.extensionContext?.inputItems != nil {
        
            for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
                
                guard let attachements = item.attachments else {
                    log.debug(String.warningGet +  "Did not get any attachments from item in [NSExtensionItem] ")
                    return
                }//guard
                
                for provider in attachements as! [NSItemProvider] {
                    if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                        log.debug("Found an image in NSExtensionItem")
                        
                        provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (data, error) in
                            if let error = error {
                                log.error(String.errorGeneral + error.localizedDescription)
                            }
                            OperationQueue.main.addOperation {
                                var contentData: Data? = nil
                                
                                if let data = data as? Data {
                                    log.debug("Setting contentData = data")
                                    contentData = data
                                } else if let url = data as? URL {
                                    log.debug("trying to set contentData to Data(contentsOf: url) ")
                                    contentData = try? Data(contentsOf: url)
                                }else if let imageData = data as? UIImage {
                                    log.debug("Setting contentData = UIImagePNGRepresentation(imageData) ")
                                    contentData = UIImagePNGRepresentation(imageData)
                                }
                                if let contentData = contentData{
                                    log.debug("We have contentData!")
                                    let photoAsset = Photo(data: contentData)
                                    log.debug("Setting let photoAsset = Photo(data: contentData)")
                                    log.debug("Presenting Photo Editor")
                                    self.presentPhotoEditorController(photoAsset: photoAsset)
                                }//contentData
                            }//OperationQueue
                        })//provider.loadItem
                    }//if provider
                }//for provider
            }//for item
        }//if self.extensionContext
    }//doesNSExtentionItemHavePhoto
    
    func presentPhotoEditorController(photoAsset: Photo){
        let configuration = buildConfiguration()
        log.debug("Setting up photoEditViewController with configuration")
        let photoEditViewController = PhotoEditViewController(photoAsset: photoAsset, configuration: configuration)
        self.present(photoEditViewController, animated: true, completion: nil)
    }
    
 
    
    func getPhotoRollAccessibilityAndRequestIfNeeded(completion: @escaping (_ isAccesible: Bool)->Void) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                log.debug(String.complete + "Photo library authorized" )
                completion(true)
            case .restricted, .denied :
                log.debug(String.warningGeneral +  "Photo library was restricted, denied or not determined")
                completion(false)
            case .notDetermined :
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (didAllow) in
                    log.debug("Camera was allowed = \(String(describing: didAllow))")
                    completion(didAllow)
                })
                
            }
        }
    }
    
/******************** Do i need this??? **************/
/*
 func getCameraAccessibilityAndRequestIfNeeded(completion: @escaping (_ isAccesible: Bool)->Void) {
 let authorizationState = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
 switch authorizationState {
 case .notDetermined:
 AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (didAllow) in
 log.debug("Camera was allowed = \(String(describing: didAllow))")
 completion(didAllow)
 })
 case .restricted, .denied:
 log.debug("Camera access restricted or denied")
 log.warning(String.warningGeneral + "Camera access restricted or denied")
 completion(false)
 case .authorized:
 log.debug(String.complete + "Camera access authorized")
 completion(true)
 
 }
 }
 */
    
}//extension


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


/*
 
 // Get the item[s] we're handling from the extension context.
 
 // For example, look for an image and place it into an image view.
 // Replace this with something appropriate for the type[s] your extension supports.
 var imageFound = false
 for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
 for provider in item.attachments! as! [NSItemProvider] {
 if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
 // This is an image. We'll load it, then place it in our image view.
 
 provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (data, error) in
 OperationQueue.main.addOperation {
 var contentData: Data? = nil
 
 if let data = data as? Data {
 contentData = data
 } else if let url = data as? URL {
 contentData = try? Data(contentsOf: url)
 }else if let imageData = data as? UIImage {
 contentData = UIImagePNGRepresentation(imageData)
 }
 if let contentData = contentData{
 let photo = Photo(data: contentData)
 self.presentPhotoEditorController(photoAsset: photo)
 }
 }
 })
 
 imageFound = true
 break
 }
 }
 
 if (imageFound) {
 // We only handle one image, so stop looking for more.
 break
 }
 }
 }
 
 
 
 
 */



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
        
        let photo = Photo.init(image: userChosenPhotoFromGalleryOrCamera.image!)
        present(createPhotoEditViewController(with: photo), animated: true )
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
}


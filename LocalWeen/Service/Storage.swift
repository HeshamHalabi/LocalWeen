//
//  Storage.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/3/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import Foundation

import UIKit
import FirebaseStorage
import FirebaseStorageUI
import SwiftyBeaver

struct StorageHandler {
    
    private var imageData = Data()
    private let childName:String = String.kImageName
    
    private var imageReference: StorageReference {
        return Storage.storage().reference().child(childName)
    }
    
    func upLoad(imageToUpload: UIImage) -> String {
        
        let image = imageToUpload
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
            log.error(String.errorSet + "saving imagedata to Firebase")
            log.debug(String.errorSet + "saving imagedata to Firebase")
            return "" }
        
        let metadata = StorageMetadata()
        metadata.contentType = String.kMetaImgFormat // static let kMetaImgFormat = "image/jpeg"
        let formatter = DateFormatter()
        formatter.dateFormat = String.kdateFormat //static let kdateFormat = "MM_DD_yyyy_hh_mm_ss"
        let filename = "\(formatter.string(from: NSDate() as Date)).jpg"
        let uploadImageRef = imageReference.child(filename)
        
        
        let uploadTask = uploadImageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if metadata == nil{
                log.error(String.errorSet + "metadata is nil")
            }
            if error != nil {
                log.error( String.errorSet + "\(String(describing: error))")
            }
            
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            log.verbose(print(snapshot.progress ?? log.verbose(String.complete)))
        }
        
        uploadTask.resume()
        log.debug("Upload \(filename)")
        return filename
    }//upload
    
    
    func downLoad(filename: String, imageView: UIImageView){
        log.debug("Download \(filename)")
        let reference = imageReference.child(filename)
        
        imageView.sd_setShowActivityIndicatorView(true)
        imageView.sd_setIndicatorStyle(.gray)
        imageView.sd_setImage(with: reference, placeholderImage: String.kPhotoPlaceholder) { (image, error, cacheType, ref ) in
            if let error = error {
                log.error(String.errorGet + "image " + error.localizedDescription )
            }//error
            
            if let image = image {
                log.debug(image)
            }
            
            log.debug(ref)
         
        }//sd_setImage
    }//downLoad
}

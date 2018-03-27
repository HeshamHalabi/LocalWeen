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
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return "" }
        
        let metadata = StorageMetadata()
        metadata.contentType = String.kMetaImgFormat
        let formatter = DateFormatter()
        formatter.dateFormat = String.kdateFormat
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
    
    func downLoad(filename: String) -> UIImageView{
        log.debug("Download \(filename)")
        let reference = imageReference.child(filename)
        let imageView: UIImageView = UIImageView()
        imageView.sd_setImage(with: reference)
        return imageView
    }
}

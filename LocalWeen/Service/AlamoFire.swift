//
//  AlamoFire.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/28/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import FirebaseStorage
import SwiftyBeaver

struct Alamo {
    
    //don't know how to get url for firebase
    
    func getImage(){
        
        let url:String = String.kStorageURL + String.kImageName + "03_86_2018_10_56_09.jpg" //as a test
        let downloader = ImageDownloader()
        let urlRequest = URLRequest(url: URL(string: url)!)
        downloader.download(urlRequest) { response in
            
            if let error = response.error {
                log.error(String.errorGet + "Image from Firebase", error.localizedDescription)
            }
            
            if let request = response.request {
                log.debug("Request for image \(String(describing: request))")
            }
            
            if let image = response.result.value {
                log.debug(String.complete + "\(response.result.isSuccess)")
                
                log.debug(image)
            }
        }
    
    
    
    
   
    }
    
    
    
}

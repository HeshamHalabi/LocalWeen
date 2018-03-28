//
//  AlamoViewController.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/28/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class AlamoViewController: UIViewController {
    
    @IBOutlet weak var alamoImage: UIImageView!
    let alamoService = Alamo()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //storageRef = storage.getReferenceFromUrl(firebaseRefURL).child(imagePath);
        //
        //  getDownloadURL().then(function(url) {
        // Insert url into an <img> tag to "download"
 //        }).catch(function(error) {

        
        let placeholderImage = UIImage(named: "picture_add")!
        let url:String = String.kStorageURL + String.kImageName + "/03_86_2018_10_56_09.jpg"
        let myURL:URL = URL(string: url)!
        alamoImage.af_setImage(withURL: myURL,
                               placeholderImage: placeholderImage,
                               filter: nil,
                               progress: nil,
                               progressQueue:  DispatchQueue.init(label: "imageDownLoad") ,
                               imageTransition: UIImageView.ImageTransition.curlUp(0.2),
                               runImageTransitionIfCached: true) { (response) in
                                
                                if let request = response.request {
                                     log.debug("\(String(describing: request))")
                                }
                                
                                if let response = response.response {
                                    log.debug("\(String(describing: response))")
                                }
                                
                                
                                if let error = response.error {
                                    log.error(String.errorGet + error.localizedDescription)
                                }
                                
                              
                                
                                if response.result.isFailure {
                                    log.error(String.errorGet +  "response from storage url request")
                                }
        }//response

    }//viewDidLoad

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
}

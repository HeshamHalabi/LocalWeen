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
        
        let placeholderImage = UIImage(named: "picture_add")!
        let url:String = String.kStorageURL + String.kImageName + "03_86_2018_10_56_09.jpg"
        let myURL:URL = URL(string: url)!
        alamoImage.af_setImage(withURL: myURL , placeholderImage: placeholderImage)
        alamoImage.af_setImage(withURL: myURL, placeholderImage: placeholderImage, filter: nil, progress: { (progress) in
            print("progress")
        }, progressQueue:  DispatchQueue.init(label: "imageDownLoad") , imageTransition: UIImageView.ImageTransition.curlUp(0.2), runImageTransitionIfCached: true) { (response) in
            print("something")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
}

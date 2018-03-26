//
//  LegalViewController.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/5/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
import WebKit

class LegalViewController: UIViewController {
    
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL (string: .AppWebSiteURL)
        let request = NSURLRequest(url: url! as URL)
        webView.load(request as URLRequest)
    }
}

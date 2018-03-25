//
//  AppDelegate.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/2/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import GoogleMaps
import GooglePlaces
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import SwiftyBeaver
import FBSDKLoginKit
import FirebaseFacebookAuthUI


class socialProfile{
    var fullName = ""
    var usrEmail = ""
    var provider = ""
    var usrUniqueID = ""
}

let social = socialProfile()
let log = SwiftyBeaver.self
let authUI = FUIAuth.defaultAuthUI()
let common = commonUI()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let orientationLock = UIInterfaceOrientationMask.portrait
    let myOrientation: UIInterfaceOrientationMask = .portrait
    
    //MARK: Force portrait orientation
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return myOrientation
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupSwiftyBeaverLogging()
        
        //Google Firebase
        FirebaseApp.configure()
        
        //Google Maps
        GMSServices.provideAPIKey("AIzaSyCAL3awSh-YPf9HwawGLjBjukc6Kz9478k")
        //Google Places
        GMSPlacesClient.provideAPIKey("AIzaSyD2RJCP9eoFaL3HPPfbYaetg_8BWhXCa24")
        
        //Google sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        //Facebook sign in
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        
        return true
    }
    
    func setupSwiftyBeaverLogging(){
    
        let format = "$C$L$c:$l:$DHH:mm:ss$d$C$N.$F()$c:$M"
        let console = ConsoleDestination()
        console.format = format
        log.addDestination(console)
        let platform = SBPlatformDestination(appID: "pgxG5z",
                                             appSecret: "rYlivwwdlfaKyfBSbhgU8yNmt5bcNNdn",
                                             encryptionKey: "RlrWwk0ciktIadaslZ17oenoabydnzyy")
        platform.format = format
        log.addDestination(platform)
        let file = FileDestination()
        file.format = format
        log.addDestination(file)

    }
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let googleAuthentication = GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        return googleAuthentication
    }
}

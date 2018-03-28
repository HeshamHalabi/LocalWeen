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
import PhotoEditorSDK


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
    
    
    //MARK: PhotoEditorSDK support
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        log.debug("Activating PhotoEditorSDK License")
        // Activate Photo Editor SDK license
        if let licenseURL = Bundle.main.url(forResource: "ios_license", withExtension: "dms") {
            PESDK.unlockWithLicense(at: licenseURL)
        } else {
            log.debug("Could not get ios_license")
        }
        
        return true
    }
    
    //MARK: Force portrait orientation
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return myOrientation
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupSwiftyBeaverLogging()
        
        //Google Firebase
        FirebaseApp.configure()
        
        //Google Maps
        GMSServices.provideAPIKey(.GServicesKey)
        //Google Places
        GMSPlacesClient.provideAPIKey(.GPlacesKey)
        
        //Google sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        //Facebook sign in
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        
        return true
    }
    
    func setupSwiftyBeaverLogging(){
    
        let format = String.logFormat
        let console = ConsoleDestination()
        console.format = format
        log.addDestination(console)
        let platform = SBPlatformDestination(appID: String.SwiftyAppID,
                                             appSecret: String.SwiftySecret,
                                             encryptionKey: String.encryptionKey)
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

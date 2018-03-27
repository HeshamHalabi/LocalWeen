//
//  WeclomeViewController.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/2/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftyBeaver
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import FBSDKLoginKit

class WelcomeViewController: UIViewController, FUIAuthDelegate{
    
    fileprivate let fbLoginButton = FBSDKLoginButton()

    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
        FUIFacebookAuth(),
        //FUITwitterAuth(),
        //FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()),
        ]
    
    lazy var dbHandler:DBHandler = DBHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        if FBSDKAccessToken.current() != nil{
            log.verbose("Facebook token is not nil, go to map")
            performSegue(withIdentifier: .kSegueToMap, sender: self)
        }

        let fbLoginButton = FBSDKLoginButton()
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = String.kFBPermissions
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let authUI = FUIAuth.defaultAuthUI() else {
            log.error(String.errorGet + "\(String(describing: FUIAuth.defaultAuthUI()))")
            common.showAlert(withTitle: String.errorGeneral, message: .kSignInError)
            return
        }
        
        authUI.isSignInWithEmailHidden = true
        authUI.delegate = self as FUIAuthDelegate
        authUI.providers = providers
        
        //hide the back button of navigation view controller, as it is not needed here
        //Handles an edge case where user CANCELED sign in and got to the welcome screen again
        self.navigationItem.hidesBackButton = true
        
        let authViewController = authUI.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        
        
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            log.verbose("Handled URL")
            return true
        }
            log.warning(String.warningGet + "URL")
        return false
    }
    
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        
        guard let uid = user?.uid else {
            log.warning(String.warningGet + "user.id")
            return
        }
        
        social.usrUniqueID = uid

        guard let pData = user?.providerData else {
            log.warning(String.warningGet + "user.providerData")
            return
        }
        
        for data in pData {
            if data.providerID != "" {
                social.provider = data.providerID
            } else {
                log.warning(String.warningGet + "data.providerID")
            }
            
        }//data
        
        if let error = error {
            log.error(String.errorGeneral + error.localizedDescription)
            common.showAlert(withTitle: .errorGeneral, message: .kSignInError)
        }
        
        guard let user = user else {
            log.error(String.errorGet + "user")
            return
        }
        log.verbose(String.complete + "\(String(describing: user))")
        
        guard let email = user.email else {
            log.warning(String.warningGet + "\(String(describing: user))")
            return
        }
        social.usrEmail = email
        
        guard let displayName = user.displayName else {
            log.warning(String.warningGet +  "\(String(describing: user)) ")
            return
        }
        social.fullName = displayName
        
//need provider
        
        dbHandler.addUser(email: social.usrEmail, fullName: social.fullName, provider: social.provider)
   
        performSegue(withIdentifier: .kSegueToMap, sender: self)
    }
    
}//WelcomeViewController


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

class WelcomeViewController: UIViewController, FUIAuthDelegate{
    
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
       // FUIFacebookAuth(),
        //FUITwitterAuth(),
        //FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()),
        ]
    
    lazy var dbHandler:DBHandler = DBHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let authUI = FUIAuth.defaultAuthUI() else {
            log.error("Could not initialize Firebase Auth UI")
            showAlert(withTitle: "Error", message: "Error getting sign in")
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
            log.warning("Could not handle URL")
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let error = error {
            log.error("A SignIn error occured", error.localizedDescription)
            showAlert(withTitle: "SignIn ERROR", message: "There was a problem signing in, please try again or check your network connection")
        }
        guard let user = user else {
            log.error("Could not get the user")
            return
        }
        log.verbose("Authorization Succesful \(String(describing: user))")
        
        guard let email = user.email else {
            log.warning("Could not get email from user: \(String(describing: user))")
            return
        }
        social.usrEmail = email
        social.profileSource = .google
        guard let displayName = user.displayName else {
            log.warning("Could not get name for user: \(String(describing: user)) ")
            return
        }
        social.usrFirstName = displayName
        social.usrLastName = ""
        dbHandler.addUser(email: social.usrEmail, firstName: social.usrFirstName, lastName: social.usrLastName, source: .google)
        performSegue(withIdentifier: "toMap", sender: self)
    }
    
    fileprivate func showAlert(withTitle title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }//showAlert
    
}//WelcomeViewController


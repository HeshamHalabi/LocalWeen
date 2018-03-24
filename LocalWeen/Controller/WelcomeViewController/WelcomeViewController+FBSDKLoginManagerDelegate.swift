//
//  WelcomeViewController+FBSDKLoginManagerDelegate.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/22/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import SwiftyBeaver
import FirebaseAuth
import FirebaseFacebookAuthUI
import FirebaseAuthUI
import FBSDKLoginKit

extension WelcomeViewController: FBSDKLoginButtonDelegate {
        
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith loginResult: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            common.showAlert(withTitle: "Error", message: "Problem logging in, please try again or check your network connection")
            log.error("Error with Facebook login \(String(describing: error.localizedDescription))")
        } else if loginResult.isCancelled {
            log.verbose("loginResult.isCancelled")
            return
        } else {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    common.showAlert(withTitle: "Error", message: error as! String)
                    log.error("Error authorizing with Firebase", error as! String)
                    
                    return
                }//error
                //Successful log in
                
                log.verbose("Successful Firebase Auth")
                
                let params = ["fields": "email, first_name, last_name, picture"]
                FBSDKGraphRequest(graphPath: "me", parameters: params).start(completionHandler: { connection, graphResult, error in
                    if let error = error {
                        log.error("Error getting FB social info \(String(describing: error))")
                        return
                    }//error
                    let fields = graphResult as? [String:Any]
                    
                    log.verbose("\(String(describing: fields))")
                    
                    guard let email = fields!["email"] else {
                        log.warning("Can't get email")
                        return
                    }
                    
                    social.usrEmail = email as! String
                    log.verbose("Got email \(String(describing: email))")
                    
                    guard let fullName = fields!["first_name"] else {
                        log.warning("Can't get first_name")
                        return
                    }
                    social.fullName = fullName as! String
                    log.verbose("Got Full Name = \(fullName)")
                  
                    self.dbHandler.addUser(email: social.usrEmail, fullName: social.fullName, provider: social.provider )
                    
                    }//FBSDKGraphRequest
                ) //Graph completion handler //FBSDKGraphRequest
            }//Auth
        }//else
        
        performSegue(withIdentifier: "toMap", sender:self)
        
    }//loginButton
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        //FBSDKAccessToken.setCurrent(nil)
        log.verbose("No idea what this method does")
        return true
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        FBSDKAccessToken.setCurrent(nil)
        common.showAlert(withTitle: "Success", message: "Successfully Logged out")
    }//loginButtonDidLogOut
}


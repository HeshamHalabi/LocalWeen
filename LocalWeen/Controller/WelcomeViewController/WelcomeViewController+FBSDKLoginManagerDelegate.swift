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
            common.showAlert(withTitle: .errorGeneral, message: .kSignInError)
            log.error(String.errorGeneral + "\(String(describing: error.localizedDescription))")
        } else if loginResult.isCancelled {
            return
        } else {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    common.showAlert(withTitle: .errorGeneral, message: error as! String)
                    log.error(String.errorGeneral, error as! String)
                    
                    return
                }//error
                //Successful log in
                
                social.usrUniqueID = (Auth.auth().currentUser?.uid)!
                log.verbose(String.complete)
                
                let params = String.kFBDetailPermissions
                    FBSDKGraphRequest(graphPath: "me", parameters: params).start(completionHandler: { connection, graphResult, error in
                    if let error = error {
                        log.error(String.errorGet +  "\(String(describing: error))")
                        return
                    }//error
                    let fields = graphResult as? [String:Any]
                    
                    log.verbose("\(String(describing: fields))")
                    
                    guard let email = fields![String.kEmail] else {
                        log.warning(String.warningGeneral)
                        return
                    }
                    
                    social.usrEmail = email as! String
                    log.verbose(String.complete + "\(String(describing: email))")
                    
                    guard let fullName = fields![String.kFirstName] else {
                        log.warning(String.warningGet + String.kFirstName)
                        return
                    }
                    social.fullName = fullName as! String
                    log.verbose(String.complete + "\(fullName)")
                  
                    self.dbHandler.addUser(email: social.usrEmail, fullName: social.fullName, provider: social.provider )
                    
                    }//FBSDKGraphRequest
                ) //Graph completion handler //FBSDKGraphRequest
            }//Auth
        }//else
        
        performSegue(withIdentifier: .kSegueToMap, sender:self)
        
    }//loginButton
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        log.verbose("No idea what this method does")
        return true
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        common.showAlert(withTitle: .complete, message: "Successfully Logged out")
    }//loginButtonDidLogOut
}


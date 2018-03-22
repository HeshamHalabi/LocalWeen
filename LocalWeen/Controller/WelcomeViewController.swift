//
//  WeclomeViewController.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/2/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import FirebaseAuth
import SwiftyBeaver


fileprivate enum Defaults {
    static let buttonTopAnchor: CGFloat = 70.0
    static let buttonLeadingAnchor: CGFloat = 32.0
    static let buttonTrailingAnchor: CGFloat = 32.0
    static let facebookLoginButtonHeight: CGFloat = 40.0
}

class WelcomeViewController: UIViewController {
    
    fileprivate let fbLoginButton = FBSDKLoginButton()
    fileprivate let googleSignInButton = GIDSignInButton()
    lazy var dbHandler:DBHandler = DBHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //hide the back button of navigation view controller, as it is not needed here
        //Handles an edge case where user CANCELED sign in and got to the welcome screen again
        self.navigationItem.hidesBackButton = true
        
        //if user already logged in to FB, go to map
        if FBSDKAccessToken.current() != nil{
            log.verbose("FBSDKAccessToken.current() != nil, goToMap")
            goToMap()
        }
        initialUISetups()
    }
    
    // MARK: - Initial UI Setups
    fileprivate func initialUISetups() {
        facebookButtonSetup()
        googleButtonSetup()
    }
    
    // MARK: Facebook Sign In Button Setup
    
    fileprivate func facebookButtonSetup() {
        // Facebook Login Button Setups
        fbLoginButton.readPermissions = ["email","public_profile"]
        view.addSubview(fbLoginButton)
        fbLoginButton.delegate = self
        if let facebookButtonHeightConstraint = fbLoginButton.constraints.first(where: { $0.firstAttribute == .height }) {
            fbLoginButton.removeConstraint(facebookButtonHeightConstraint)
        }
        // Add Constraints to fb login button
        fbLoginButton.translatesAutoresizingMaskIntoConstraints = false
        fbLoginButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Defaults.buttonTopAnchor).isActive = true
        fbLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Defaults.buttonLeadingAnchor).isActive = true
        fbLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Defaults.buttonTrailingAnchor).isActive = true
        fbLoginButton.heightAnchor.constraint(equalToConstant: Defaults.facebookLoginButtonHeight).isActive = true
    }
    
    // MARK: Google Sign In Button Setup
    
    fileprivate func googleButtonSetup() {
        // Google Sign In Button Setups
        view.addSubview(googleSignInButton)
        googleSignInButton.style = .wide
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        // Add Constraints to Google Sign In Button
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.topAnchor.constraint(equalTo: fbLoginButton.topAnchor, constant: Defaults.buttonTopAnchor).isActive = true
        googleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Defaults.buttonLeadingAnchor).isActive = true
        googleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Defaults.buttonTrailingAnchor).isActive = true
    }
    
    
    // Basic Alert View
    fileprivate func showAlert(withTitle title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    private func goToMap(){
        performSegue(withIdentifier: "toMap", sender: self)
    }//goToMap
    
}//fetchUserProfileData

// MARK: - Facebook SDK Button Delegates
extension WelcomeViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith loginResult: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            showAlert(withTitle: "Error", message: error.localizedDescription)
            log.error("Error on Facebook login \(String(describing: error.localizedDescription))")
        } else if loginResult.isCancelled {
            log.verbose("loginResult.isCancelled")
            return
        } else {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    self.showAlert(withTitle: "Error", message: error as! String)
                    log.error("Error authorizing with Firebase", error as! String)
                
                    return
                }//error
                //Successful log in
             
                log.verbose("Auth.auth().signIn Successful Firebase Auth")
                
                let params = ["fields": "email, first_name, last_name, picture"]
                FBSDKGraphRequest(graphPath: "me", parameters: params).start(completionHandler: { connection, graphResult, error in
                    if let error = error {
                        log.error("Error getting FB social info \(String(describing: error))")
                        return
                    }//error
                    let fields = graphResult as? [String:Any]
                    
                    log.verbose("FBSDKGraphRequest graphResults")
                    log.verbose("\(String(describing: fields))")
                    
                    guard let email = fields!["email"] else {
                        log.warning("FBSDKGraphRequest can't get email")
                        return
                    }
                    
                    social.usrEmail = email as! String
                    log.verbose("FBSDKGraphRequest got email \(String(describing: email))")
                    
                    guard let firstName = fields!["first_name"] else {
                        log.warning("FBSDKGraphRequest can't get first_name")
                        return
                    }
                    social.usrFirstName = firstName as! String
                    log.verbose("FBSDKGraphRequest got first_name \(String(describing: firstName))")
                    
                    guard let lastName = fields!["last_name"] else {
                        log.warning("FBSDKGraphRequest can't get last_name")
                        return
                    }
                    
                    social.usrLastName = lastName as! String
                    log.verbose("FBSDKGraphRequest got last_name \(String(describing: lastName))")
                    
                    self.dbHandler.addUser(email: social.usrEmail, firstName: social.usrFirstName, lastName: social.usrLastName)
                    
                   /*********
                     FOR THE MOMENT, FORGET ABOUT THE PHOTO!
 ************/
                    
                }//FBSDKGraphRequest
            ) //Graph completion handler //FBSDKGraphRequest
        }//Auth
    }//else
        self.goToMap()
}//loginButton
                  
  
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        showAlert(withTitle: "Success", message: "Successfully Logged out")
    }
}

// MARK: - Google Sign In Delgates
extension WelcomeViewController: GIDSignInUIDelegate {
    
}

extension WelcomeViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error) != nil {
            log.error("Either the user already signed out or an error occured during Google Authentication")
            log.error(error.localizedDescription)
            return
        }//error
        
        if user.profile.email != nil {
            social.usrEmail = user.profile.email
        } else {
            log.warning("Could not get social.usrEmail")
        }//social.usrEmail
        
        log.verbose("social.usrEmail = \(String(describing: social.usrEmail))")
        
        if user.profile.givenName != nil {
        
            social.usrFirstName = user.profile.givenName
            
        } else {
            log.warning("Google sign in - could not get user given name")
        }//social.usrGivenName
        
        log.verbose("social.usrGivenName = \(String(describing: social.usrFirstName))")
        
        if user.profile.familyName != nil {
            social.usrLastName = user.profile.familyName
            
        } else {
            log.warning("Google sign in - could not get user familyName")
        }//social.usrFamilyName
        
        log.verbose("social.usrFamilyName = \(String(describing: social.usrFirstName))")
        
        if user.profile.hasImage {
            guard let url = (user.profile.imageURL(withDimension: 120)) else {
                log.warning("user.profile.imageURL is not found")
                return
            }//let url
        
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    log.warning("ERROR session.dataTask \(error)")
                }//let error
        if let data = data {
            social.usrProfilePhoto  = UIImage(data: data)!
            log.verbose("social.usrProfilePhoto SUCCESS ")
        } else {
            log.warning("WelcomeViewController: GIDSignInUIDelegate-sign-social.usrProfilePhoto FAILED")
        }//let data
        
                }.resume() //session.dataTask
        }//if user.profile.hasImage
        
        self.dbHandler.addUser(email: social.usrEmail, firstName: social.usrFirstName, lastName: social.usrLastName)
        
        guard let authentication = user.authentication else {
            log.error("Firebase Authentication failed")
            return
            
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
        accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if (error) != nil {
                log.error("Google Authentification Failed \(String(describing: error?.localizedDescription))")
            } else {
                log.verbose("Google Authentification Success")
                self.goToMap()
        }//error
    }//Auth
}//sign
    
    func getImageFromUrl(sourceUrl: String) -> UIImage? {
        if let url = URL(string: sourceUrl) {
            if let imageData = try? Data(contentsOf:url) {
                return UIImage(data: imageData)
            }
        }
        return nil
    }
}//extention



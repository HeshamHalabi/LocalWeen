//
//  Statics.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/26/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    //MARK: General
    static let kdateFormat = "MM_DD_yyyy_hh_mm_ss"
    static let kSignInError = "There was a problem signing in, please try again or check your network connection"
    static let kPhotoPlaceholder:UIImage = #imageLiteral(resourceName: "icons8-panorama")
    
    //MARK: Map
    static let locationOfInterestImageName = "hhouseicon"
    static let userMarkerImageName = "witchicon"
    static let possibleAdd =  "questionMapMaker"
    static let kAppleMapsURL = "http://maps.apple.com/maps?saddr="
    
    //MARK Segue Identifiers
    static let kSegueToMap = "toMap"
    static let kSegueBACKToMap =  "backToMap"
    static let kSegueToLocationDetails = "toDetail"
    
    //MARK: Google
    static let GServicesKey = "AIzaSyCAL3awSh-YPf9HwawGLjBjukc6Kz9478k"
    static let GPlacesKey = "AIzaSyD2RJCP9eoFaL3HPPfbYaetg_8BWhXCa24"
    
    //MARK: SwiftyBeaver
    static let logFormat = "$C$L$c:$l:$DHH:mm:ss$d$C$N.$F()$c:$M"
    static let SwiftyAppID = "pgxG5z"
    static let SwiftySecret = "rYlivwwdlfaKyfBSbhgU8yNmt5bcNNdn"
    static let encryptionKey  = "RlrWwk0ciktIadaslZ17oenoabydnzyy"
    
    //MARK: Logging Strings
    static let warningGet = "WARNING: Unable to get "
    static let warningSet = "WARNING: Unable to set "
    static let warningGeneral = "WARNING: "
    static let errorGet = "ERROR: Unable to get "
    static let errorSet = "ERROR: Unable to set "
    static let errorGeneral = "ERROR: "
    static let complete = "COMPLETE: "
    static let debug = "DEBUG: "
    
    
    //MARK: App Website
    static let AppWebSiteURL = "https://sites.google.com/view/localween/home/legal"
    
    //MARK: Data Related
    static let locationsChild = "locations"
    static let usersChild = "users"
    static let kLattitude = "latitude"
    static let kLongitude = "longitude"
    static let kImageName = "images"
    static let kRating = "rating"
    static let kEmail = "usrEmail"
    static let kFirebaseID = "firebaseUID"
    static let kPostDate = "postDate"
    static let kFullName = "full_name"
    static let kProvider = "provider"
    
    //MARK: Storage Related
    static let kMetaImgFormat = "image/jpeg"
    
    
    
    //MARK Facebook Permissions
    static let kFBPermissions = ["public_profile", "email"]
    static let kFBDetailPermissions = ["fields": "email, first_name, last_name, picture"]
    static let kFirstName = "first_name"
    
    //MARK: Alerts
    static let kAgreementTitle = "Save Agreement"
    static let kAgreementDetails = "You certify that you are not submitting a location for any illegal or unethical reason.  You agree to all of LocalWeen's legal such as Terms of Service"
    static let kPhotoSource = "Photo Source"
    static let kPhotoSourceChoice = "Choose a source"
    static let kCameraText = "Camera"
    static let kPhotoLibraryText = "Library"
    
}

//
//  Database.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/3/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import FirebaseDatabase
import CoreLocation
import SwiftyBeaver


class DBHandler{
 
    var ref:DatabaseReference! = Database.database().reference().child(.locationsChild)
    var userRef:DatabaseReference! = Database.database().reference().child(.usersChild)
    
    func getFor(coordinateIn:CLLocationCoordinate2D?, what: String, completion: @escaping ([Any]) -> ())  {
        log.debug("What = " + what)
        
        var ratings = [Double]()
        var fileNames = [String]()
        var coordinates = [CLLocationCoordinate2D]()
        
        self.ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot =  snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot {
                    if let data = snap.value as? [String:Any]{
                        //Get the latitude and longitude for matching
                        guard let latitude = data[.kLattitude] else {
                            
                            log.warning(String.warningGet + .kLattitude)
                            return
                        }
                        guard let longitude = data[.kLongitude] else {
                             log.warning(String.warningGet + .kLongitude)
                            return
                        }
                        
                        let coordFromDB = CLLocationCoordinate2DMake(latitude as! CLLocationDegrees, longitude as! CLLocationDegrees)
                        
                        var isMatch = Bool()
                        isMatch = false
                        
                        if coordinateIn != nil {
                            isMatch = self.matchCoords(coordinateIn: coordinateIn!, coordFromDB: coordFromDB)
                        }//if coordinateIn
                        
                        switch what {
                         
                            case "filename":
                                if (data["image_name"] as! String).isEmpty == false {
                                    if let imageName = data["image_name"] as? String {
                                        fileNames.append(imageName)
                                    }//if let
                                }//if data
    
                            
                            case "ratings":
                            
                                guard let ratingData = data[.kRating] else {
                                    log.warning(String.warningGet + .kRating)
                                    return
                                }
                                
                                if isMatch {
                                    
                                    let rating = ratingData as! Double
                                    if rating >= 1.0 {
                                        ratings.append(rating)
                                    } else {
                                       log.warning(String.warningGet + .kRating + " less than 1")
                                    }
                                    ratings.append(rating)
                                }//isMatch
    
                            case "coordinate":
                                coordinates.append(coordFromDB)
                            default:
                                return
                        }//switch
                    }//data
                }//for
            }//snapshot
            
            if what == "ratings" {
                completion(ratings)
            } else if what == "filename" {
                log.debug(String.complete + "returning filenames")
                completion(fileNames)
            } else {
                completion(coordinates)
            }
        }//ref
    }//get
    
    private func matchCoords(coordinateIn:CLLocationCoordinate2D, coordFromDB:CLLocationCoordinate2D) -> Bool {

        if coordinateIn.latitude == coordFromDB.latitude && coordinateIn.longitude == coordFromDB.longitude {
            return true
        } else {
            return false
        }
    }//matchCoords

    
    func addLocation(coordinate:CLLocationCoordinate2D, rating: Double, imageName: String?){
        let location = [.kLattitude: coordinate.latitude,
                        .kLongitude: coordinate.longitude,
                        .kRating: rating,
                        .kImageName: imageName!,
                        .kEmail: social.usrEmail,
                        .kFirebaseID: social.usrUniqueID,
                        .kPostDate: ServerValue.timestamp()
            ] as [String : Any]
        self.ref.childByAutoId().setValue(location)
        log.verbose("\(String(describing: location))")
    }//end setLocation
    
    func addUser(email: String, fullName: String, provider: String){
        
        
        let userData = [.kEmail: email,
                        .kFullName: fullName,
                        .kProvider: provider,
                        .kFirebaseID: social.usrUniqueID,
                        .kPostDate: ServerValue.timestamp()
            ] as [String : Any]
        self.userRef.childByAutoId().setValue(userData)
        log.verbose("\(String(describing: userData))")
    }//addUser
    
}//DBHandler
    

    

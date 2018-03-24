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
    var ref:DatabaseReference! = Database.database().reference().child("locations")
    var userRef:DatabaseReference! = Database.database().reference().child("users")
    
    func getFor(coordinateIn:CLLocationCoordinate2D?, what: String, completion: @escaping ([Any]) -> ())  {
        
        var ratings = [Double]()
        var fileNames = [String]()
        var coordinates = [CLLocationCoordinate2D]()
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot =  snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot {
                    if let data = snap.value as? [String:Any]{
                        //Get the latitude and longitude for matching
                        guard let latitude = data["latitude"] else {
                            
                            log.warning("DBHandler Could not get lattitude in getFor request")
                            return
                        }
                        guard let longitude = data["longitude"] else {
                             log.warning("DBHandler Could not get longitude in getFor request")
                            return
                        }
                    
                        let coordFromDB = CLLocationCoordinate2DMake(latitude as! CLLocationDegrees, longitude as! CLLocationDegrees)
                        
                        var isMatch = Bool()
                        isMatch = false
                        
                        if coordinateIn != nil {
                            isMatch = self.matchCoords(coordinateIn: coordinateIn!, coordFromDB: coordFromDB)
                        }//if coordinateIn
                        
                        switch what {
                           
                            case "fileNames":
                                guard let filename = data["image_name"] else {
                                   log.warning("DBHandler Can't get filename for image")
                                    return
                                }
                                if isMatch {
                                        fileNames.append(filename as! String)
                                }//if isMatch
                            
                            case "ratings":
                            
                                guard let ratingData = data["rating"] else {
                                    log.warning("DBHandler Can't get ratingData")
                                    return
                                }
                                
                                if isMatch {
                                    
                                    let rating = ratingData as! Double
                                    if rating >= 1.0 {
                                        ratings.append(rating)
                                    } else {
                                       log.warning("DBHandler ratingData Rating was less than 1")
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
            if what == "ratings"{
                completion(ratings)
            } else if what == "fileNames" {
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
        let location = ["latitude": coordinate.latitude,
                        "longitude": coordinate.longitude,
                        "rating": rating,
                        "image_name": imageName!,
                        "usrEmail": social.usrEmail,
                        "postDate": ServerValue.timestamp()
            ] as [String : Any]
        self.ref.childByAutoId().setValue(location)
        log.verbose("Location data is: \(String(describing: location))")
    }//end setLocation
    
    func addUser(email: String, fullName: String, provider: String){
        
        
        let userData = ["email": email,
                        "full_name": fullName,
                        "provider": provider,
                        "postDate": ServerValue.timestamp()
            ] as [String : Any]
        self.userRef.childByAutoId().setValue(userData)
        log.debug("Provider = \(provider)")
        log.verbose("addUser \(String(describing: userData))")
    }//addUser
    
}//DBHandler
    

    

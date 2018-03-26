//
//  MapViewController+GMSAutocomplete.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/15/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//
import GooglePlaces
import GoogleMaps
import SwiftyBeaver

extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        singleSearchResult = place.coordinate
        
        if resultMarker.map != nil {
            resultMarker.map = nil
        }
        
        segueWhat = dataToSegue.searchResult
        searchController?.isActive = false
        // Do something with the selected place.
        
        resultMarker.map = self.mapView
        resultMarker.icon = UIImage(named: questionMarker)
        resultMarker.position = place.coordinate
        self.mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: zoom, bearing: 0, viewingAngle: 0)
        
        log.verbose("\(String(describing: singleSearchResult ))")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        log.error( String.errorGeneral + error.localizedDescription )
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

//
//  MapViewController+GMSAutocomplete.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/15/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//
import GooglePlaces
import GoogleMaps
extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        singleSearchResult = place.coordinate
        segueWhat = dataToSegue.searchResult
        searchController?.isActive = false
        // Do something with the selected place.
        placeMarker(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, imageName: questionMarker)
        self.mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: zoom, bearing: 0, viewingAngle: 0)
        searchCoordinates = place.coordinate
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

//
//  MapViewController+SearchBar.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/14/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import GooglePlaces
import GoogleMaps
import UIKit

extension MapViewController {
    
    func setupSearchBar(){
        
        //Search Bar
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self as GMSAutocompleteResultsViewControllerDelegate
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRect(x: 0, y: 60.0, width: 350.0, height: 45.0))
        
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }
    
}

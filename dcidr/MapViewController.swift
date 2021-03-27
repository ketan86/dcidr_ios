//
//  MapViewController.swift
//  dcidr
//
//  Created by John Smith on 1/28/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
class MapViewController : BaseViewController {
    
    
    var mLatitude : Double!
    var mLongitude: Double!
    var mMarkerTitle: String!
    var mMarkerSnippet: String!
    @IBAction func mResetToMyLocation(_ sender: UIBarButtonItem) {
        let camera = GMSCameraPosition.camera(withLatitude: self.mLatitude, longitude: self.mLongitude, zoom: 12)
        self.mGoogleMapView.camera = camera
    }
    @IBOutlet weak var mGoogleMapView: GMSMapView!
    override func viewDidLoad() {
        self.showUIActivityIndicator()
        self.setUserFetchDoneCb({
            self.initViewController()
            self.stopUIActivityIndicator()
        })
        super.viewDidLoad()
    }
    
    override func handleInputDataDict(data: [String: Any]?) {
        if let dict = data {
            for (key,value) in dict {
                if(key == "mLatitude") {
                    self.mLatitude = value as! Double
                }else if(key == "mLongitude") {
                    self.mLongitude = value as! Double
                }else if(key == "mMarkerTitle") {
                    self.mMarkerTitle = value as! String
                }else if(key == "mMarkerSnippet") {
                    self.mMarkerSnippet = value as! String
                }
            }
        }
    }
    
    override func initViewController() {
        
        
        
        
        let camera = GMSCameraPosition.camera(withLatitude: self.mLatitude, longitude: self.mLongitude, zoom: 12)
        self.mGoogleMapView.camera = camera
        
        
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: self.mLatitude, longitude: self.mLongitude))
        marker.title = self.mMarkerTitle
        marker.snippet = self.mMarkerSnippet
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = self.mGoogleMapView
        
        
    }
    
    @IBAction func onCancelButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}

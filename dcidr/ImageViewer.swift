//
//  ImageViewer.swift
//  dcidr
//
//  Created by John Smith on 2/21/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class ImageViewer: Comparable {
    
    fileprivate var mCreatedByUserName: String?
    fileprivate var mLastModifiedTime: Int64?
    fileprivate var mImageServerUrl: String?
    fileprivate var mImage: UIImage?
    
    // comparable protocol implementation
    static func < (lhs: ImageViewer, rhs: ImageViewer) -> Bool {
        return lhs.mLastModifiedTime! < rhs.mLastModifiedTime!
    }
    
    static func > (lhs: ImageViewer, rhs: ImageViewer) -> Bool {
        return lhs.mLastModifiedTime! > rhs.mLastModifiedTime!
    }
    
    static func == (lhs: ImageViewer, rhs: ImageViewer) -> Bool {
       return lhs.mLastModifiedTime! == rhs.mLastModifiedTime!
    }
    
    init(){
    }
    
    func setLastModifiedTime(lastModifiedTime: Int64){
        self.mLastModifiedTime = lastModifiedTime
    }
    
    func getLastModifiedTime() -> Int64{
        return mLastModifiedTime!
    }
    func getImageServerUrl() -> String{
        return self.mImageServerUrl!
    }
    func setImageServerUrl(imageServerUrl: String){
        self.mImageServerUrl = imageServerUrl
    }
//    public URI getImageLocalUrl(){
//        return mImageLocalUrl;
//    }
//    public void setImageLocalUrl(URI imageLocalUrl){
//        mImageLocalUrl = imageLocalUrl;
//    }
    func setImage(image: UIImage){
        self.mImage = image
    }
    func getImage() -> UIImage{
        return self.mImage!
    }
    
    func setCreatedByUserName(userName: String){
        self.mCreatedByUserName = userName
    }
    
    func getCreatedByUserName() -> String{
        return self.mCreatedByUserName!
    }
    
    func populateMe(_ jsonObj : JSON) {
        if jsonObj["lastModifiedTime"].exists() {
            self.setLastModifiedTime(lastModifiedTime: jsonObj["lastModifiedTime"].int64Value)
        }
        if jsonObj["mediaUrl"].exists() {
            self.setImageServerUrl(imageServerUrl: jsonObj["mediaUrl"].stringValue)
        }
        if jsonObj["firstName"].exists() {
            self.setCreatedByUserName(userName: jsonObj["firstName"].stringValue + " " + jsonObj["lastName"].stringValue)
        }
    }
    
    
}

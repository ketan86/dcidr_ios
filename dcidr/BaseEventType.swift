//
//  BaseEventType.swift
//  dcidr
//
//  Created by John Smith on 12/30/16.
//  Copyright © 2016 dcidr. All rights reserved.

import Foundation
import SwiftyJSON
import Hex
class BaseEventType {
    fileprivate var mEventTypeColor: UIColor!
    fileprivate var mEventTypeIcon : UIImage!
    fileprivate var mEventType: String? = nil
    fileprivate var mEventTypeId: Int64 = -1
    required init(){
        self.mEventTypeColor = UIColor(hex: "11232")
        self.mEventTypeIcon = UIImage(named: "mountain_icon")
    }
    
    func getEventType() -> String? {
        return self.mEventType
    }
    
    func setEventType(_ type: String) {
        self.mEventType = type
    }
    
    func getEventTypeIcon() -> UIImage {
        return self.mEventTypeIcon
    }
    
    func getEventTypeColor() -> UIColor {
        return self.mEventTypeColor
    }
    
    func getEventTypeId() -> Int64 {
        return self.mEventTypeId
    }
    
    func setEventTypeId(_ id: Int64) {
        self.mEventTypeId = id
    }
    
    func populateMe(_ jsonObj: JSON) {
        if jsonObj["eventType"].exists() {
            self.mEventType = jsonObj["eventType"].stringValue
        }
        if jsonObj["eventTypeId"].exists() {
            self.mEventTypeId = jsonObj["eventTypeId"].int64Value
        }
    }
    
}

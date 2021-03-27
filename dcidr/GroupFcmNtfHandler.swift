//
//  GroupFcmNtfHandler.swift
//  dcidr
//
//  Created by John Smith on 3/5/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class GroupFcmNtfHandler : BaseFcmNtfHandler {
    
    fileprivate var mGroupId: Int64!
    fileprivate var mSrcUserId: Int64!
    override init(jsonMetadataObject: JSON, source: String) {
        super.init(jsonMetadataObject: jsonMetadataObject, source: source)
    }

    func handleNtf(jsonObject: JSON) {
        let groupJsonObj = jsonObject["GROUP"]
        self.mGroupId = groupJsonObj["groupId"].int64Value
        if(groupJsonObj["userId"].exists()) {
            mSrcUserId = groupJsonObj["userId"].int64Value
        }else {
            print("[handleNtf] srcUserId is null")
        }
        if (self.mNotificationCode == NotificationCodes.GROUP_CREATE_NTF_CODE) {
            self.handleGroupCreateNtf(jsonObject: groupJsonObj)
        }else {
            print("[handleNtf] Invalid notification code")
        }
        
    }
    
    func handleGroupCreateNtf(jsonObject: JSON){
    
        DcidrApplication.getInstance().getGlobalGroupContainer().populateGroup([jsonObject])
        let baseGroup = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId)
        baseGroup?.unreadEventCount += 1
        
        let keyValue: [String: Any] = [
            "viewController" : "GroupViewController",
        ]
        self.sendNotification(userId: self.mSrcUserId, title: "Dcidr Notification", body: jsonObject["groupName"].stringValue + " Group created by " + self.mJsonMetadataObj["srcUserName"].stringValue, keyValue: keyValue)
    }
    
}

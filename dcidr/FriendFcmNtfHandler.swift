//
//  FriendFcmNtfHandler.swift
//  dcidr
//
//  Created by John Smith on 3/25/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON

class FriendFcmNtfHandler : BaseFcmNtfHandler {
    
    fileprivate var mSrcUserId: Int64!
    override init(jsonMetadataObject: JSON, source: String) {
        super.init(jsonMetadataObject: jsonMetadataObject, source: source)
    }
    
    func handleNtf(jsonObject: JSON) {
        let friendJsonObj = jsonObject["FRIEND"]
        if(friendJsonObj["userId"].exists()) {
            mSrcUserId = friendJsonObj["userId"].int64Value
        }else {
            print("[handleNtf] srcUserId is null")
        }
        if (self.mNotificationCode == NotificationCodes.FRIEND_INVITE_NTF_CODE) {
            self.handleFriendInviteNtf(jsonObject: friendJsonObj)
        }else {
            print("[handleNtf] Invalid notification code")
        }
        
    }
    
    func handleFriendInviteNtf(jsonObject: JSON){
    
        let keyValue: [String: Any] = [
            "viewController" : "ContactInvitationViewController",
            "data" : [
                "ACTION" : "INVITE",
                "MSG" : jsonObject
                ]
            ]
        self.sendNotification(userId: self.mSrcUserId, title: "Dcidr Notification", body: self.mJsonMetadataObj["srcUserName"].stringValue + " invited you to become a friend ", keyValue: keyValue)
    }
    
}

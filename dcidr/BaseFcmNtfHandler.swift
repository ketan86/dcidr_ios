//
//  BaseFcmNtfHandler.swift
//  dcidr
//
//  Created by John Smith on 3/2/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import UserNotifications
class BaseFcmNtfHandler {
    internal var mNotificationCode: Int!
    internal var mJsonMetadataObj: JSON!
    internal var mSource: String!
    
    init(jsonMetadataObject: JSON, source: String){
            self.mJsonMetadataObj = jsonMetadataObject
            self.mSource = source
            // extract notification code
            self.mNotificationCode = jsonMetadataObject["notificationCode"].intValue
    }
    
    func sendNotification(userId: Int64, title: String, body: String, keyValue: Dictionary<String, Any>) {
    
        // check if ntf setting is enabled
        if let ntfEnabled = DcidrApplication.getInstance().getUserCache().getPref("NtfEnabled") {
            if(ntfEnabled == "false"){
                return
            }
        }
    
        // TODO Enable it later
        // do not show notification created by the same user
        //if(DcidrApplication.getInstance().getUser().getUserId() == userId){
        //    return
        //}
    
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                print("notifications are not allowed")
            }else{
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default()
                content.userInfo = keyValue as [String: Any]
                let identifier = "DcidrLocalNotification"
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                                repeats: false)
                let request = UNNotificationRequest(identifier: identifier,
                                                    content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                    if error != nil {
                        print("error creating a local notification")
                    }
                })
            }
        }

        

    }

}

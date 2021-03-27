//
//  FcmListenerService.swift
//  dcidr
//
//  Created by John Smith on 2/26/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import SwiftyJSON
class FcmListenerService {
    let mFcmMessageIDKey = "gcm.message_id"
    static let fcmListenerService : FcmListenerService = FcmListenerService()
    fileprivate let mFcmMessagingService = FcmMessagingService()
    static func getInstance() -> FcmListenerService {
        return fcmListenerService
    }
    
    fileprivate init(){
        FIRApp.configure()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            
        }
    }
    
    
    func handleMessage(ntf: [AnyHashable : Any]){
        self.mFcmMessagingService.onMessageReceived(ntf: ntf)

    }
    
    @objc func tokenRefreshNotification(_ notification: Notification) {
        // Connect to FCM since connection may have failed when attempted before having a token.
        self.connectToFcm()
        self.sendTokenToSever(successCb: {
            () -> Void in
            print("token sent to server success")
        }, failureCb: {
            () -> Void in
            print("token sent to server failure")

        })
    }

    func sendTokenToSever(successCb: @escaping () -> Void, failureCb: @escaping ()-> Void) {
        if let fcmRegToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(fcmRegToken)")
            
            let userAsyncHttpClient = UserAsyncHttpClient()
            var userMap = Dictionary<String, String>()
            userMap["fcmRegToken"] = fcmRegToken
            // use object may not yet be populated so using useId from cache
            userAsyncHttpClient.updateUserDevice(userIdStr: DcidrApplication.getInstance().getUserCache().getPref("userId")!, userMap: userMap, respHandler: {
                (statusCode, resp) in
                if let statusCode: Int = statusCode {
                    if let respValue = resp.value {
                        let json = JSON(respValue)
                        if(statusCode ==  200) {
                            print("fcm token updated on server")
                            successCb()
                        }else {
                            print(json["error"].string!)
                            failureCb()
                        }
                    }else {
                        if(statusCode ==  200) {
                            print("fcm token updated on server")
                            successCb()
                        }else {
                            failureCb()
                        }
                    }
                }else {
                    print("error updating token on server")
                    failureCb()
                }

            })
        }
    }
    
    func connectToFcm() {
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            return;
        }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func disconnectFcm(){
        FIRMessaging.messaging().disconnect()
    }
}

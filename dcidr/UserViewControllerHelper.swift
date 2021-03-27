//
//  UserViewControllerHelper.swift
//  dcidr
//
//  Created by John Smith on 1/7/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class UserViewControllerHelper {
    
    fileprivate var mBaseViewController:BaseViewController!
    fileprivate var mUserFetchDoneCb:() -> () = {
        () -> () in
    }
    init(baseViewController: BaseViewController){
        self.mBaseViewController = baseViewController
    }
    
    func setUserFetchDoneCb(_ cb: @escaping ()-> ()) {
        self.mUserFetchDoneCb = cb
    }
    
    func clearUserCache(){
        print("[clearUserCache] Clearing user cache")
        DcidrApplication.getInstance().getUserCache().clear()
    }
    
//    func clearNotifications(){
//    print("[clearNotifications] Clearing user notifications")
    // clear all notification form notification bar since user is logging out
//    NotificationManager notificationManager = (NotificationManager) mBaseActivity.getBaseContext()
//    .getSystemService(Context.NOTIFICATION_SERVICE);
//    notificationManager.cancelAll();
//    }
   
    func clearAppState(){
        print("[clearAppState] Clearing the application state")
        DcidrApplication.getInstance().clear()
    }
    
    func logoutUser(){
        clearUserCache()
        //clearNotifications();
    
        // based on loginType, perform logout
//        if(DcidrApplication.getInstance().getUser().getLoginType() == User.LoginType.FACEBOOK) {
//        LoginManager.getInstance().logOut();
//        }else if (DcidrApplication.getInstance().getUser().getLoginType() == User.LoginType.GOOGLE) {
//        if (DcidrApplication.getInstance().getGoogleApiClient().isConnected()) {
//        DcidrApplication.getInstance().getGoogleApiClient().disconnect();
//        }
//        } else if (DcidrApplication.getInstance().getUser().getLoginType() == User.LoginType.DCIDR) {
//        // no need to do anything for dcidr logout
//        }
        // clear application state
        clearAppState()
        
        // finish caller activity and go back to login activity
        self.mBaseViewController.dismiss(animated: true, completion: nil)
        launchLoginActivity()
    }
    
    func getUserEmailFromCache() -> String? {
        if let userEmail = DcidrApplication.getInstance().getUserCache().getPref("emailId"){
                return userEmail
        }
        return nil
    }
    func getUserIdFromCache() -> String? {
        if let userId = DcidrApplication.getInstance().getUserCache().getPref("userId") {
            return userId
        }
        return nil
    }
    
    func launchLoginActivity(){
        print("[launchLoginActivity] Launching login activity")
        // launch login controller
        let loginViewCtr = self.mBaseViewController.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.mBaseViewController.present(loginViewCtr, animated: true, completion: nil)

    }
    
    func initUser(){
        if let userId = self.getUserIdFromCache() {
            self.mBaseViewController.showUIActivityIndicator()
            let userAsyncHttpClient = UserAsyncHttpClient()
            userAsyncHttpClient.getUser(userId, respHandler: {
            (statusCode, resp) in
                self.mBaseViewController.stopUIActivityIndicator()
                if let statusCode = statusCode {
                        if(statusCode == 200){
                            if let respValue = resp.value {
                                let json = JSON(respValue)
                                DcidrApplication.getInstance().getUser().populateMe(json["result"])
                                self.mUserFetchDoneCb()
                            }else {
                                self.mBaseViewController.showAlertMsg("error getting data from server")
                            }
                        }else {
                            if let respValue = resp.value {
                                let json = JSON(respValue)
                                self.mBaseViewController.showAlertMsg(json["error"].stringValue)
                            }else {
                                self.mBaseViewController.showAlertMsg("error getting user info")
                            }
                        }
                }else {
                    self.mBaseViewController.showAlertMsg("error connecting to server")
                }
            })
        }else {
            print("userId not found")
        }
    }
}

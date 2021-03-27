////
////  BaseLoginViewControllerHelper.swift
////  dcidr
////
////  Created by John Smith on 1/5/17.
////  Copyright © 2017 dcidr. All rights reserved.
////
//
//import Foundation
//
///**
//* Created by Turbo on 2/10/2016.
//*/

import SwiftyJSON

class BaseLoginViewControllerHelper {
    internal var  mBaseViewController : BaseViewController!
    private let TAG : String
    internal var mUserAsyncHttpClient: UserAsyncHttpClient
    private var mCreateUserFlag: Bool
    //
    //    /**
    //    * constructor for base login ViewController helper. other login helpers extend this class
    //    * @param ViewController : ViewController context
    //    */
    init( baseViewController: BaseViewController) {
        self.mBaseViewController = baseViewController
        self.TAG = "BaseLoginViewControllerHelper"
        self.mUserAsyncHttpClient = UserAsyncHttpClient()
        self.mCreateUserFlag = false
    }
    
    /**
     * method for setting cache for user
     * @param key : name of cache
     * @param value : value of cache
     */
    func setUserCache( key : String,  value: String) {
        print(TAG + "[setUserCache] Setting user cache")
        DcidrApplication.getInstance().getUserCache().updatePref(key, value: value)
    }

    
    /**
     * method for setting user on DB. it will get userId in response.
     */
    func createUser(emailIdStr: String) -> () {
        print (TAG + "[createUser] Sending new singin request to server")
        mCreateUserFlag =  true;
        mUserAsyncHttpClient.createUser(emailIdStr: emailIdStr, user: DcidrApplication.getInstance().getUser()) {
            (statusCode, resp) -> () in
            if let statusCode = statusCode {
                if (statusCode == 200 || statusCode == 201) {
                    if ((self.mBaseViewController as? LoginViewController) != nil) {
                        //this means that the mBaseViewController can be interpreted as a LoginViewController
                        //We can only proceed if this is the case
                        let loginViewController: LoginViewController  = self.mBaseViewController as! LoginViewController
                        let viewctr = loginViewController.storyboard?.instantiateViewController(withIdentifier: "SignupVerifyCodeViewController") as! SignupVerifyCodeViewController
                        loginViewController.present(viewctr, animated: true, completion: nil)
                    }
                } else {
                    if let respValue = resp.value {
                        let json = JSON(respValue)
                        self.mBaseViewController.showAlertMsg(json["error"].stringValue)
                    }
                }
            } else {
                self.mBaseViewController.showAlertMsg("error connecting to server")
            }
        }
    }
}

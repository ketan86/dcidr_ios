	//
//  DcidrLoginViewControllerHelper.swift
//  dcidr
//
//  Created by John Smith on 1/7/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class DcidrLoginViewControllerHelper: BaseLoginViewControllerHelper {
    // login page init
    //private var mSignupUserProfilePicImage: UIImage
    fileprivate var TAG: String = "DcidrLoginViewControllerHelper"
    
    override init(baseViewController: BaseViewController) {
        super.init(baseViewController: baseViewController)        
    }
    
    func onLoginButtonClicked(_ sender: UIButton) {
        if ((mBaseViewController as? LoginViewController) != nil) {
            //this means that the mBaseViewController can be interpreted as a LoginViewController
            //We can only proceed if this is the case
            let loginViewController: LoginViewController  = mBaseViewController as! LoginViewController
            
            loginViewController.showUIActivityIndicator()
            self.mUserAsyncHttpClient.loginUser(loginViewController.loginEmailText!.text!,
                                                passwordDigest: HMAC.hash(loginViewController.loginPasswordText!.text!, algo: HMACAlgo.sha256)) {
                (statusCode, resp) -> () in
                //self.stopUIActivityIndicator()
                if(statusCode == 200){
                    let json = JSON(resp.value!)
                    // set userid in user object
                    loginViewController.user.userId = json["userId"].string!
                    // set authToken in cache
                    DcidrApplication.getInstance().getUserCache().updatePref("authToken", value: json["authToken"].string!)
                    // set emailId in cache
                    DcidrApplication.getInstance().getUserCache().updatePref("emailId", value: loginViewController.loginEmailText.text!)
                    // set userId in cache
                    DcidrApplication.getInstance().getUserCache().updatePref("userId", value: loginViewController.user.userId)
                    
                    
                    let fcmListenerService = FcmListenerService.getInstance()
                    fcmListenerService.sendTokenToSever(successCb:  {
                        () -> Void in
                        // launch main controller
                        let MainViewCtr = loginViewController.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                        loginViewController.present(MainViewCtr, animated: true, completion: nil)
                    }, failureCb: {
                        loginViewController.showAlertMsg("unexpected error. please try again later")
                    })
                    
                }else {
                    if let respValue = resp.value {
                        let json = JSON(respValue)
                        loginViewController.showAlertMsg((json["error"].string)!)
                    }else {
                        loginViewController.showAlertMsg("error connecting server")
                    }
                    
                }
            }
        }
    }
    
    func onSignupButtonClicked(_ sender: UIButton)
    {
        //self.showUIActivityIndicator()
        let user: User = DcidrApplication.getInstance().getUser()
        user.loginType = User.LoginType.DCIDR
        DcidrApplication.getInstance().getUserCache().updatePref("loginType", value: String(describing: user.loginType))
        //populate global user object
        user.loginType = User.LoginType.DCIDR
        if ((mBaseViewController as? LoginViewController) != nil) {
            //this means that the mBaseViewController can be interpreted as a LoginViewController
            //We can only proceed if this is the case
            let loginViewController: LoginViewController  = mBaseViewController as! LoginViewController
            
            if let firstName: String = loginViewController.signupFirstName.text {
                if(firstName.isEmpty == true) {
                    //showAlertMsg("first name is mandatory")
                    return
                }
                user.firstName = firstName
            } else {
                loginViewController.showAlertMsg("first name is mandatory")
                return
            }
        
            if let lastName: String = loginViewController.signupLastName!.text {
                if(lastName.isEmpty) {
                    loginViewController.showAlertMsg("last name is mandatory")
                    return
                }
                user.lastName = lastName
            } else {
                loginViewController.showAlertMsg("last name is mandatory")
                return
            }
        
            let emailId:String = loginViewController.signupEmailText!.text!
            if(emailId.isEmpty == true) {
                loginViewController.showAlertMsg("email is mandatory")
                return
            }
            user.emailId = emailId

        
            if let password: String = loginViewController.signupPasswordText!.text {
                if(password.isEmpty == true) {
                    loginViewController.showAlertMsg("password is mandatory")
                    return
                }
                user.passwordDigest = HMAC.hash(password, algo: HMACAlgo.sha256)
            } else {
                loginViewController.showAlertMsg("password is mandatory")
                return
            }
            print(TAG + "[login] Requesting new user creation")
            self.createUser(emailIdStr: emailId)
        }
    }
    
}

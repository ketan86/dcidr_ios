//
//  SignupVerifyCodeViewController.swift
//  dcidr
//
//  Created by John Smith on 12/28/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
class SignupVerifyCodeViewController: BaseViewController {
    
    var userAsyncHttpClient = UserAsyncHttpClient()
    var user: User = DcidrApplication.getInstance().getUser()
    override func viewDidAppear(_ animated: Bool) {
        self.showAlertMsg("Verification code sent to your email")

    }
    
    override func handleInputDataDict(data: [String: Any]?) {
    }
    override func viewDidLoad() {
        
    }
        
    @IBOutlet weak var resendConfCodeButton: UIBarButtonItem!
    @IBOutlet weak var confCode1TextField: UITextField!
    @IBOutlet weak var confCode2TextField: UITextField!
    @IBOutlet weak var confCode3TextField: UITextField!
    @IBOutlet weak var confCode4TextField: UITextField!
    @IBOutlet weak var submitConfCodeButton: UIButton!
    
    @IBAction func onCancelButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onConfCode1EditingChanged(_ sender: UITextField) {
        if(sender.text?.characters.count == 1) {
            self.confCode2TextField.becomeFirstResponder()
        }
    }
    @IBAction func onConfCode2EditingChanged(_ sender: UITextField) {
        if(sender.text?.characters.count == 1) {
            self.confCode3TextField.becomeFirstResponder()
        }
    }
    @IBAction func onConfCode3EditingChanged(_ sender: UITextField) {
        if(sender.text?.characters.count == 1) {
            self.confCode4TextField.becomeFirstResponder()
        }
    }
    
    fileprivate func getConfCode() -> String {
        return self.confCode1TextField.text! + self.confCode2TextField.text! +
            self.confCode3TextField.text! + self.confCode4TextField.text!
    }
    
    @IBAction func onResendConfCodeOnClicked(_ sender: UIBarButtonItem) {
        self.confCode1TextField.text = ""
        self.confCode2TextField.text = ""
        self.confCode3TextField.text = ""
        self.confCode4TextField.text = ""
        self.confCode1TextField.becomeFirstResponder()
        
        self.showUIActivityIndicator()
//        self.userAsyncHttpClient.singupUser(self.user.emailId) { (statusCode, resp) -> () in
//            self.stopUIActivityIndicator()
//            if(statusCode == 200){
//               self.showAlertMsg("Verification code sent to your email")
//            }else {
//                let json = JSON(resp.value!)
//                self.showAlertMsg((json["error"].string)!)
//            }
//        }
    }
    
    @IBAction func onSubmitConfCode(_ sender: UIButton) {
        self.showUIActivityIndicator()
        self.userAsyncHttpClient.verifyUser(self.user.emailId, confCode: self.getConfCode()) { (statusCode, resp) -> () in
            self.stopUIActivityIndicator()
            if(statusCode == 200){
                // create user
                self.showUIActivityIndicator()
                self.userAsyncHttpClient.createUser(self.user) { (statusCode, resp) -> () in
                    self.stopUIActivityIndicator()
                    if(statusCode == 200){
                        let json = JSON(resp.value!)
                        // set userid in user object
                        self.user.userId = json["userId"].string!
                        // set authToken in cache
                        DcidrApplication.getInstance().getUserCache().updatePref("authToken", value: json["authToken"].string!)
                        // set emailId in cache
                        DcidrApplication.getInstance().getUserCache().updatePref("emailId", value: self.user.emailId)
                        // set userId in cache 
                        DcidrApplication.getInstance().getUserCache().updatePref("userId", value: self.user.userId)

                        // init user class by making request to db
                        let userViewControllerHelper: UserViewControllerHelper =  UserViewControllerHelper(baseViewController: self)
                        userViewControllerHelper.initUser()

                        //                          TODO: FCM/GCM workflow TBD
                        //                          SetDeviceCallbackRunnable setDeviceRunnableCallback = new SetDeviceCallbackRunnable();
                        //                          DcidrApplication.getInstance().setDeviceCallbackRunnable(setDeviceRunnableCallback);
                        //                          MyInstanceIDListenerService myInstanceIDListenerService = new MyInstanceIDListenerService();
                        //                          myInstanceIDListenerService.refreshToken(mBaseActivity);
                        //                          Utils.hideSoftKeyboard(mBaseActivity);

                        let fcmListenerService = FcmListenerService.getInstance()
                        fcmListenerService.sendTokenToSever(successCb:  {
                            () -> Void in
                            let MainViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                            self.present(MainViewCtr, animated: true, completion: nil)
                        }, failureCb: {
                            self.showAlertMsg("unexpected error. please try again later")
                        })
                        
                        
                        
                        //set the user image either from DCIDR, Facebook or Google
//                        self.mUserAsyncHttpClient.setUserMedia(userIdStr: self.user.userId , base64Str: DcidrApplication.getInstance().getUser().userProfilePicBase64Str,
//                                                               mediaType: "image") {
//                                                                (statusCode, resp) -> () in
//                                                                if let statusCode = statusCode {
//                                                                    if (statusCode == 200 || statusCode == 201) {
//                                                                        // set user populated to true
//                                                                        DcidrApplication.getInstance().getUser().isPopulated = true
//                                                                        if let respValue = resp.value {
//                                                                            let json: String? = JSON(respValue).string
//                                                                            print("User Image Set with value " + json!);
//                                                                        }
//                                                                    } else {
//                                                                        print("User Image could not be set")
//                                                                    }
//                                                                }
//                        }
                        
                    }else {
                        let json = JSON(resp.value!)
                        self.showAlertMsg((json["error"].string)!)
                    }
                }
                
            }else {
                let json = JSON(resp.value!)
                self.showAlertMsg((json["error"].string)!)
            }
        }
    }
    
}

//
//  LoginViewController.swift
//  dcidr
//
//  Created by John Smith on 12/26/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import UIKit
import SwiftyJSON
class LoginViewController : BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate{
    
    @IBOutlet var mLoginMainView: UIView!
    fileprivate var mFacebookViewControllerHelper:FacebookLoginViewControllerHelper!
    fileprivate var mDcidrLoginViewControllerHelper: DcidrLoginViewControllerHelper!
    fileprivate var mGoogleLoginViewController : GoogleLoginViewController!
    fileprivate var mUserCache = DcidrApplication.getInstance().getUserCache()
    @IBOutlet weak var loginPage: UIButton!
    @IBOutlet weak var signupPage: UIButton!
    //@IBOutlet weak var userProfilePicView: UIButton!
    
    let user: User = DcidrApplication.getInstance().getUser()
    var userAsyncHttpClient = UserAsyncHttpClient()
    
    @IBOutlet weak var loginEmailText: UITextField!
    @IBOutlet weak var loginPasswordText: UITextField!
    @IBOutlet weak var signupEmailText: UITextField!
    @IBOutlet weak var signupPasswordText: UITextField!
    @IBOutlet weak var signupFirstName: UITextField!
    @IBOutlet weak var signupLastName: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!

    var imagePicker = UIImagePickerController()

    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var signupStackView: UIStackView!

    override func viewDidLoad() {
        signupStackView.isHidden = true
        loginStackView.isHidden = false
        // check if userId is stored in usercache
        self.showUIActivityIndicator()
        self.setUserFetchDoneCb({
        () -> () in
            self.initViewController()
            self.stopUIActivityIndicator()
        })
        
        // call super method after setting userFetchCbFunction
        super.viewDidLoad()
        
        // hide keyboard when touched outside
        self.mLoginMainView.isUserInteractionEnabled = true
        self.mLoginMainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(_:))))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // init facebook, dcidr and google login
        self.mFacebookViewControllerHelper = FacebookLoginViewControllerHelper(baseViewController: self)
        self.mDcidrLoginViewControllerHelper = DcidrLoginViewControllerHelper( baseViewController: self)
        self.mGoogleLoginViewController = GoogleLoginViewController(baseViewController: self)

    }
    
    override func handleInputDataDict(data: [String: Any]?) {
    }
    
    //initActivity
    override func initViewController(){
        
        // set device id in userCache
        let deviceId :String = UIDevice.current.identifierForVendor!.uuidString
        self.mUserCache.updatePref("deviceId", value: deviceId)
        
        // get userId from cache
        if let userId = DcidrApplication.getInstance().getUserCache().getPref("userId") {
            
            let fcmListenerService = FcmListenerService.getInstance()
            fcmListenerService.sendTokenToSever(successCb:  {
                () -> Void in
                print("[onCreate] userId: " + userId)
                print("[onCreate] Allowing to proceed to MainViewController")
                // finish login activity and go to main VC
                let MainViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                self.present(MainViewCtr, animated: true, completion: nil)
            }, failureCb: {
                self.showAlertMsg("unexpected error. please try again later")
            })
        }
        
        // init facebook, dcidr and google login
        self.mFacebookViewControllerHelper = FacebookLoginViewControllerHelper(baseViewController: self)
        self.mDcidrLoginViewControllerHelper = DcidrLoginViewControllerHelper( baseViewController: self)
        self.mGoogleLoginViewController = GoogleLoginViewController(baseViewController: self)
    }
    
    @IBAction func onLoginPageClicked(_ sender: UIButton) {
        loginStackView.isHidden = false
        signupStackView.isHidden = true
        //userProfilePicView.isHidden = true
        //signupPage.setTitleColor(Colors.white,for: UIControlState.normal)
        //sender.setTitleColor(UIColor.yellow,for: UIControlState.normal)
    }
    
    @IBAction func onSignupPageClicked(_ sender: UIButton) {
        loginStackView.isHidden = true
        signupStackView.isHidden = false
    }
    
    @IBAction func onLoginButtonClicked(_ sender: UIButton) {
        //call the helper function onLoginButtonClicked functions
        self.mDcidrLoginViewControllerHelper.onLoginButtonClicked(sender)
    }
                
    
    //This code used to be in DcidrLoginViewControllerHelper, but we dont want to pass around
    //IBOutlet in other classes, so doing that functionality here
    @IBAction func onSignupButtonClicked(_ sender: UIButton) {
        self.mDcidrLoginViewControllerHelper.onSignupButtonClicked(sender)
    }

}


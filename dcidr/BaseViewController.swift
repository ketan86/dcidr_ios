//
//  BaseViewController.swift
//  dcidr
//
//  Created by John Smith on 12/28/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import UserNotifications

protocol ViewControllerInputDataDelegate {
    func handleInputDataDict(data: [String:Any]?)
}

class BaseViewController: UIViewController, UNUserNotificationCenterDelegate, ViewControllerInputDataDelegate {
    
    fileprivate var mCtrInputDataDict: [String: Any]? = nil
    fileprivate var mUiActivityIndicator : UIActivityIndicatorView!
    fileprivate var mUserCache: UserCache!
    private let TAG = "BaseViewController"
    private var mCreateUserFlag = false
    internal var mUserAsyncHttpClient = UserAsyncHttpClient()
    fileprivate var mUserFetchDoneCb: () -> Void = {
        () -> Void in
    }
    
    
    func dismissKeyboard(_ sender:UITapGestureRecognizer){
        	self.view.endEditing(true)
    }
    
    func setUserFetchDoneCb(_ cb: @escaping () -> Void) {
        self.mUserFetchDoneCb = cb
    }
    
    
    func initViewController() {
        
        
    }
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        // call to handle view controller data
        print(self.mCtrInputDataDict)
        self.handleInputDataDict(data: self.mCtrInputDataDict)
        
        // delegate for handling notification while app is in forground
        UNUserNotificationCenter.current().delegate = self

//        if(!isNetworkAvailable()){
//            self.showAlertMsg("no internet connection. Please check and retry.");
//            return;
//        }
        
        print("[onCreate] initializing base view controller viewWillAppear")
        
//        //if there is no SD card, create new directory objects to make directory on device
//        if (Environment.getExternalStorageState() == null) {
//            //create new file directory object
//            DCIDR_DIR = new File(Environment.getDataDirectory()
//                + "/Dcidr/");
//            // if phone DOES have sd card
//        } else if (Environment.getExternalStorageState() != null) {
//            // search for directory on SD card
//            DCIDR_DIR = new File(Environment.getExternalStorageDirectory()
//                + "/Dcidr/");
//        }
//        if(DCIDR_DIR != null) {
//            // if no directory exists, create new directory
//            if (!DCIDR_DIR.exists()) {
//                DCIDR_DIR.mkdirs();
//            }
//        }
        // check if intent is sent by gcm and clear the notifications
        //        String source = getIntent().getStringExtra(getResources().getString(R.string.source_key));
        //        if(source != null) {
        //            if(source.equals(getResources().getString(R.string.gcm_message_handler_class_name))) {
//        if(DcidrApplication.getInstance().getNtfObj() != null) {
//            DcidrApplication.getInstance().getNtfObj().clearNtfs();
//        }
    
        
        self.mUserCache = DcidrApplication.getInstance().getUserCache()
        if let userId : String = self.mUserCache.getPref("userId") {
            print(userId)
            // if user class is not populated, populate it. otherwise finish the view controller and return
            if (!DcidrApplication.getInstance().getUser().isPopulated) {
                let userViewControllerHelper: UserViewControllerHelper =  UserViewControllerHelper(baseViewController: self)
                userViewControllerHelper.setUserFetchDoneCb({
                    () -> () in
                    self.mUserFetchDoneCb()
                })
                userViewControllerHelper.initUser()
            }else {
                self.mUserFetchDoneCb()
            }
        }else {
            self.mUserFetchDoneCb()
        }
        
//        SD_IMAGE_FILE = new File(Environment.getExternalStorageDirectory(), "myImageFile.jpg");
//        CROPPED_IMAGE_FILE = new File(Environment.getExternalStorageDirectory(), "croppedImageFile.jpg");
    
        
    }
    
    func handleInputDataDict(data: [String: Any]?) {
        // child class should override to handle input data sent by caller as dict
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        let vct = self.storyboard?.instantiateViewController(withIdentifier: response.notification.request.content.userInfo["viewController"]! as! String) as! BaseViewController
        if (NSStringFromClass(vct.classForCoder) == NSStringFromClass(self.classForCoder)){
            print("view controller is already in foreground")
            self.initViewController()
            return
        }
        if let data = response.notification.request.content.userInfo["data"] {
            print(data)
            vct.mCtrInputDataDict = data as? [String: Any]
        }
        
        self.present(vct, animated: true, completion: nil)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])

    }
    
    
    func showAlertMsgWithOptions(_ title:String, textMsg : String, okCb: @escaping (UIAlertAction) -> (), cancelCb: @escaping (UIAlertAction) -> ()){
        let alert = UIAlertController(title: title, message: textMsg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: okCb))
        alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            // cancle the alert dialog and call the callback
            alert.dismiss(animated: true, completion: nil)
            cancelCb(result)
        })
        self.present(alert, animated: true, completion: nil)
    }

    func showImageAlert(_ title: String, imageData: Data, newWidth: CGFloat) {
        let imageView = UIImageView()
        imageView.image = self.resizeImage(UIImage(data: imageData)!, newWidth : newWidth)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.view.addSubview(imageView)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertMsg(_ textMsg : String){
        let alert = UIAlertController(title: "Alert", message: textMsg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showUIActivityIndicator() {
        self.mUiActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.mUiActivityIndicator.center = self.view.center
        self.mUiActivityIndicator.startAnimating()
        self.view.addSubview(self.mUiActivityIndicator)
    }
    
    func stopUIActivityIndicator() {
        self.mUiActivityIndicator.stopAnimating()
    }
    
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
        
    }
    
    

//    func createUser() -> () {
//        print(TAG + "[createUser] Sending new sign in request to server")
//        mCreateUserFlag =  true;
//        
//        mUserAsyncHttpClient.createUser(DcidrApplication.getInstance().getUser(), mUserAsyncHttpResponseHandler);
//    }

}

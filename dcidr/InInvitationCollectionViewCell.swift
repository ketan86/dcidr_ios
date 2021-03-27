//
//  InInvitationCollectionCell.swift
//  dcidr
//
//  Created by John Smith on 1/29/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class InInvitationCollectionViewCell : UICollectionViewCell {
    
    fileprivate var mBaseViewController: BaseViewController!
    fileprivate var mArrayList: Array<Contact>!
    fileprivate var mContact: Contact!
    @IBOutlet weak var mContactProfilePic: UIImageView!
    @IBOutlet weak var mContactName: UILabel!
    fileprivate let mUserIdStr: String = DcidrApplication.getInstance().getUser().getUserIdStr()
    fileprivate let mEmailIdStr: String = DcidrApplication.getInstance().getUser().emailId

    @IBOutlet weak var mContactDeclineButton: UILabel!
    @IBOutlet weak var mContactAcceptButton: UILabel!
    
    func setCellData(_ baseViewController: BaseViewController, arrayList: Array<Contact>){
        self.mBaseViewController = baseViewController
        self.mArrayList = arrayList
    }
    
    func getCellView(indexPath: IndexPath) -> InInvitationCollectionViewCell {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hex: Colors.md_gray_400).cgColor
        self.mContact = self.mArrayList[indexPath.row]
        self.mContactName.text  = self.mContact.getUserName()
        
        // set default image image due to reusability of the cell
        self.mContactProfilePic.image = UIImage(named: "user_default_icon")
        self.mContactProfilePic.layer.borderWidth = 0
        self.mContactProfilePic.layer.cornerRadius = self.mContactProfilePic.frame.height / 2
        self.mContactProfilePic.clipsToBounds = true
        self.mContactProfilePic.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
        if(self.mContact.getUserProfilePicData() == nil) {
            self.mContact.setUserProfilePicFetchDoneCb({ (imageData : Data?) in
                if(imageData != nil) {
                    self.mContactProfilePic.image = self.mBaseViewController.resizeImage(UIImage(data: imageData!)!, newWidth : 500)
                }
            })
        }else {
            self.mContactProfilePic.image = self.mBaseViewController.resizeImage(UIImage(data: self.mContact.getUserProfilePicData()!)!, newWidth : 500)
        }
        return self
    }
    
    
    @IBAction func mContactAcceptButtonClicked(_ sender: UIButton) {
        self.mBaseViewController.showAlertMsgWithOptions("Invititation", textMsg: "Are you sure you want to accept the invitation ?", okCb: { (_) in
            // send invitation
            let userAsyncHttpClient = UserAsyncHttpClient()
            userAsyncHttpClient.acceptInvitation(userIdStr: self.mUserIdStr, userEmailId: self.mEmailIdStr, friendIdStr: self.mContact.getUserIdStr(), friendEmailId: self.mContact.emailId, respHandler: { (statusCode, resp) in
                if let statusCode: Int = statusCode {
                    let json = JSON(resp.value!)
                    if(statusCode ==  200) {
                        self.mBaseViewController.showAlertMsg("Invitation accepted")
                    }else {
                        self.mBaseViewController.showAlertMsg(json["error"].string!)
                    }
                }else {
                    self.mBaseViewController.showAlertMsg("error accepting invitation")
                }
            })
        }) { (_) in
            // no-op
        }

        
    }
    
    @IBAction func mContactDeclineButtonClicked(_ sender: UIButton) {
        
        self.mBaseViewController.showAlertMsgWithOptions("Invititation", textMsg: "Are you sure you want to decline the invitation ?", okCb: { (_) in
            // send invitation
            let userAsyncHttpClient = UserAsyncHttpClient()
            userAsyncHttpClient.declineInvitation(userIdStr: self.mUserIdStr, userEmailId: self.mEmailIdStr, friendIdStr: self.mContact.getUserIdStr(), friendEmailId: self.mContact.emailId, respHandler: { (statusCode, resp) in
                if let statusCode: Int = statusCode {
                    let json = JSON(resp.value!)
                    if(statusCode ==  200) {
                        self.mBaseViewController.showAlertMsg("Invitation declined")
                    }else {
                        self.mBaseViewController.showAlertMsg(json["error"].string!)
                    }
                }else {
                    self.mBaseViewController.showAlertMsg("error declining invitation")
                }
            })
        }) { (_) in
            // no-op
        }
    }
    
}

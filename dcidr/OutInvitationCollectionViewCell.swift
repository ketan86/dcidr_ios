//
//  OutInvitationCollectionCell.swift
//  dcidr
//
//  Created by John Smith on 1/29/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class OutInvitationCollectionViewCell : UICollectionViewCell {
    
    fileprivate var mBaseViewController: BaseViewController!
    fileprivate var mArrayList: Array<Contact>!
    fileprivate var mContact: Contact!

    @IBOutlet weak var mContactProfilePic: UIImageView!
    @IBOutlet weak var mContactName: UILabel!
    fileprivate let mUserIdStr: String = DcidrApplication.getInstance().getUser().getUserIdStr()
    @IBOutlet weak var mContactRemindButton: UILabel!
    
    func setCellData(_ baseViewController: BaseViewController, arrayList: Array<Contact>){
        self.mBaseViewController = baseViewController
        self.mArrayList = arrayList
    }
    
    func getCellView(indexPath: IndexPath) -> OutInvitationCollectionViewCell {
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
    @IBAction func onContactRemindButtonClicked(_ sender: UIButton) {
        
        self.mBaseViewController.showAlertMsgWithOptions("Remind", textMsg: "Are you sure you want to remind ?", okCb: { (_) in
            // send invitation
            let userAsyncHttpClient = UserAsyncHttpClient()
            userAsyncHttpClient.inviteContact(self.mUserIdStr, friendEmailId: self.mContact.emailId, respHandler: { (statusCode, resp) in
                if let statusCode: Int = statusCode {
                    let json = JSON(resp.value!)
                    if(statusCode ==  200) {
                    
                        self.mBaseViewController.showAlertMsg("reminder sent")
                        
                    }else {
                        self.mBaseViewController.showAlertMsg(json["error"].string!)
                    }
                }else {
                    self.mBaseViewController.showAlertMsg("error sending reminder")
                }
            })
        }) { (_) in
            // no-op
        }
    }
}

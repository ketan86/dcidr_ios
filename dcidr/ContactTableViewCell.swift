//
//  ContactTableViewCell.swift
//  dcidr
//
//  Created by John Smith on 1/29/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import UIKit
import Foundation
import Agrume
import SwiftyJSON
class ContactTableViewCell: UITableViewCell {
    
    fileprivate var mArrayList: Array<Contact>!
    fileprivate var mBaseViewController: BaseViewController!
    fileprivate var mContact: Contact!
    fileprivate let mUserIdStr: String = DcidrApplication.getInstance().getUser().getUserIdStr()

    @IBOutlet weak var mContactName: UILabel!
    
    @IBOutlet weak var mContactEmailId: UILabel!
    
    @IBOutlet weak var mContactProfilePic: UIImageView!
    
    @IBOutlet weak var mContactInviteButton: UIButton!
    @IBAction func mContactInviteButton(_ sender: UIButton) {
        self.mBaseViewController.showAlertMsgWithOptions("Invite", textMsg: "Send invitation to " + self.mContact.getUserName(), okCb: { (_) in
            // send invitation
            let userAsyncHttpClient = UserAsyncHttpClient()
            userAsyncHttpClient.inviteContact(self.mUserIdStr, friendEmailId: self.mContact.emailId, respHandler: { (statusCode, resp) in
                if let statusCode: Int = statusCode {
                    let json = JSON(resp.value!)
                    if(statusCode ==  200) {
                        
                        DcidrApplication.getInstance().getGlobalContactContainer().getContact(contactEmailId: self.mContact.emailId)?.setStatusType(Contact.StatusType.INVITED)
    
                        let contactsViewController = self.mBaseViewController as! ContactsViewController
                        contactsViewController.mContactTableView.reloadData()
                        
                        self.mBaseViewController.showAlertMsg("invitation sent")
                        
                    }else {
                        self.mBaseViewController.showAlertMsg(json["error"].string!)
                    }
                }else {
                    self.mBaseViewController.showAlertMsg("error inviting friend")
                }
            })
        }) { (_) in
            // no-op
        }
    }
    
    func setCellData(_ baseViewController: BaseViewController, arrayList: Array<Contact>){
        self.mBaseViewController = baseViewController
        self.mArrayList = arrayList
    }
    
    func getCellView(indexPath: IndexPath) -> ContactTableViewCell {
        self.mContact = self.mArrayList[indexPath.row]
        self.mContactName.text  = self.mContact.getUserName()
        self.mContactEmailId.text = self.mContact.emailId
        
        self.mContactInviteButton.isHidden = false
        // if contact is invited set string to invited, and if friend, hide the invitation button
        if(self.mContact.getStatusType() == Contact.StatusType.INVITED) {
            self.mContactInviteButton.setTitle("INVITED", for: .normal)
            self.mContactInviteButton.isEnabled = false
        }else if (self.mContact.getStatusType() == Contact.StatusType.FRIEND)  {
            self.mContactInviteButton.isHidden = true
        }
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
        // set tap gesture on mEventProfilePic
        self.mContactProfilePic.isUserInteractionEnabled = true
        self.mContactProfilePic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ContactTableViewCell.onContactProfilePicClicked)))
        return self
        
    }
    
    func onContactProfilePicClicked(imageView : UIImageView) {
        if let data = self.mContact.getUserProfilePicData() {
            let agrume = Agrume(image: UIImage(data: data)!, backgroundColor: .white)
            agrume.showFrom(self.mBaseViewController)
        }
        
    }
    
    
}

//
//  FriendPickerTableViewCell.swift
//  dcidr
//
//  Created by John Smith on 2/4/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
class FriendPickerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mUserProfilePic: UIImageView!
    @IBOutlet weak var mUserName: UILabel!
    @IBOutlet weak var mSelectedSwitch: UISwitch!
    fileprivate var mBaseViewController: BaseViewController!
    fileprivate var mArrayList: Array<Any>!
    fileprivate var mIndexPathRow: Int!
    enum ObjectType {
        case USER, GROUP
    }
    
    func setCellData(_ baseViewController: BaseViewController, arrayList: Array<Any>){
        self.mBaseViewController = baseViewController
        self.mArrayList = arrayList
    }
    
    func getCellView(indexPath: IndexPath) -> FriendPickerTableViewCell {
        self.mSelectedSwitch.isOn = false
        self.mIndexPathRow = indexPath.row
        if let user = self.mArrayList[indexPath.row] as? User {
            //let user = self.mArrayList[indexPath.row] as! User
            self.mUserName.text = user.getUserName()
            // set default image image due to reusability of the cell
            self.mUserProfilePic.image = UIImage(named: "user_default_icon")
            self.mUserProfilePic.layer.borderWidth = 0
            self.mUserProfilePic.layer.cornerRadius = self.mUserProfilePic.frame.height / 2
            self.mUserProfilePic.clipsToBounds = true
            self.mUserProfilePic.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
            if(user.getUserProfilePicData() == nil) {
                user.setUserProfilePicFetchDoneCb({ (imageData: Data?) in
                    if(imageData != nil) {
                        self.mUserProfilePic.image = self.mBaseViewController.resizeImage(UIImage(data: imageData!)!, newWidth : 500)
                    }
                })
            }else {
                self.mUserProfilePic.image = self.mBaseViewController.resizeImage(UIImage(data: user.getUserProfilePicData()!)!, newWidth : 500)
            }
            
            if(user.getIsSelected()) {
                self.mSelectedSwitch.isOn = true
            }

        }
        
        if let group = self.mArrayList[indexPath.row] as? BaseGroup {
            //let group = self.mArrayList[indexPath.row] as! BaseGroup
            self.mUserName.text = group.groupName
            // set default image image due to reusability of the cell
            self.mUserProfilePic.image = UIImage(named: "user_default_icon")
            self.mUserProfilePic.layer.borderWidth = 0
            self.mUserProfilePic.layer.cornerRadius = self.mUserProfilePic.frame.height / 2
            self.mUserProfilePic.clipsToBounds = true
            self.mUserProfilePic.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
            if(group.groupProfilePicData == nil) {
                group.setGroupProfilePicFetchDoneCb({ (imageData : Data) in
                    self.mUserProfilePic.image = self.mBaseViewController.resizeImage(UIImage(data: imageData)!, newWidth : 500)
                })
            }else {
                self.mUserProfilePic.image = self.mBaseViewController.resizeImage(UIImage(data: group.groupProfilePicData!)!, newWidth : 500)
            }
            if(group.getIsSelected()) {
                self.mSelectedSwitch.isOn = true
            }
        }
        
        self.mSelectedSwitch.addTarget(self, action: #selector(FriendPickerTableViewCell.sampleSwitchValueChanged), for: UIControlEvents.valueChanged)
        
        return self
    }
    
    
    func sampleSwitchValueChanged(sender: UISwitch) {
        let createGroupViewController: CreateGroupViewController = self.mBaseViewController as! CreateGroupViewController
        if let user =  self.mArrayList[self.mIndexPathRow] as? User {
            if sender.isOn {
                user.setIsSelected(true)
                createGroupViewController.mUserContainer.getUserMap()[user.getUserId()]?.setIsSelected(true)
            }else {
                user.setIsSelected(false)
                createGroupViewController.mUserContainer.getUserMap()[user.getUserId()]?.setIsSelected(false)
            }
        }
        
        if let group = self.mArrayList[self.mIndexPathRow] as? BaseGroup {
            if sender.isOn {
                group.setIsSelected(true)
                createGroupViewController.mGroupContainer.getBaseGroup(group.groupId)?.setIsSelected(true)
            }else {
                group.setIsSelected(false)
                createGroupViewController.mGroupContainer.getBaseGroup(group.groupId)?.setIsSelected(false)
            }
        }
    }
    
}

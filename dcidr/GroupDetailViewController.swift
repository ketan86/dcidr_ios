//
//  GroupDetailViewController.swift
//  dcidr
//
//  Created by John Smith on 2/25/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class GroupDetailViewController: BaseViewController {

    var mGroupId: Int64!
    fileprivate var mBaseGroup: BaseGroup!
    fileprivate var mMembersHolderStackView: UIStackView!
    @IBOutlet weak var mGroupProfilePic: UIImageView!
    fileprivate var mUserIdStr: String = DcidrApplication.getInstance().getUser().getUserIdStr()
    fileprivate var mUserContainer: UserContainer!
    @IBOutlet weak var mMembersHolderView: UIView!
    @IBOutlet weak var mMembersListRefLine: UIView!
    @IBOutlet weak var mPageTitle: UINavigationItem!
    @IBOutlet weak var mGroupName: UILabel!
    @IBOutlet weak var mGroupDetailScrollView: UIScrollView!
    
    override func handleInputDataDict(data: [String: Any]?) {
    }
    override func viewDidLoad() {
        self.showUIActivityIndicator()
        self.setUserFetchDoneCb({
            self.initViewController()
            self.stopUIActivityIndicator()
        })
        super.viewDidLoad()
    }
    
    @IBAction func onCancelButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    override func initViewController() {
        self.mUserContainer = UserContainer()
        self.mBaseGroup = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId)
        self.mGroupName.text = self.mBaseGroup.groupName
        self.mPageTitle.title = "Group Info"
        if(self.mBaseGroup.groupProfilePicData == nil) {
            self.mBaseGroup.setGroupProfilePicFetchDoneCb({ (imageData : Data) in
                self.mGroupProfilePic.image = UIImage(data: imageData)!
            })
        }else {
            self.mGroupProfilePic.image = UIImage(data: self.mBaseGroup.groupProfilePicData!)!
        }

        self.getGroupMembers()
    }
    
    func createMembersHolderStackView() {
        self.mMembersHolderStackView = UIStackView()
        self.mMembersHolderStackView.translatesAutoresizingMaskIntoConstraints = false
        self.mMembersHolderStackView.axis = .vertical
        self.mMembersHolderView.addSubview(self.mMembersHolderStackView)
        
        self.mMembersHolderView.addConstraint(NSLayoutConstraint(item: self.mMembersHolderStackView, attribute: .top, relatedBy: .equal, toItem: self.mMembersListRefLine, attribute: .bottom, multiplier: 1, constant: 10))
        self.mMembersHolderView.addConstraint(NSLayoutConstraint(item: self.mMembersHolderStackView, attribute: .centerX, relatedBy: .equal, toItem: self.mMembersListRefLine, attribute: .centerX, multiplier: 1, constant: 0))
        
        self.mMembersHolderView.addConstraint(NSLayoutConstraint(item: self.mMembersHolderStackView, attribute: .leading, relatedBy: .equal, toItem: self.mMembersListRefLine, attribute: .leading, multiplier: 1, constant: 0))
        self.mMembersHolderView.addConstraint(NSLayoutConstraint(item: self.mMembersHolderStackView, attribute: .trailing, relatedBy: .equal, toItem: self.mMembersListRefLine, attribute: .trailing, multiplier: 1, constant: 0))
        
        for user in self.mUserContainer.getUserList() {
            let v = UserInfoCustomView()
            v.addConstraint(NSLayoutConstraint(item: v, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 50))
            v.userName.text = user.getUserName()
            v.userProfilePic.layer.borderWidth = 0
            v.userProfilePic.layer.cornerRadius = v.userProfilePic.frame.height / 2
            v.userProfilePic.clipsToBounds = true
            if(user.getUserProfilePicData() == nil) {
                user.setUserProfilePicFetchDoneCb({ (imageData : Data?) in
                    if(imageData != nil) {
                        v.userProfilePic.image = self.resizeImage(UIImage(data: imageData!)!, newWidth : 500)
                    }
                })
            }else {
                v.userProfilePic.image = self.resizeImage(UIImage(data: user.getUserProfilePicData()!)!, newWidth : 500)
            }
            self.mMembersHolderStackView.addArrangedSubview(v)
        }
        
        self.mGroupDetailScrollView.contentSize = CGSize(width: CGFloat(self.mGroupDetailScrollView.frame.width), height: CGFloat(self.mMembersHolderStackView.subviews.count * 50) + CGFloat(self.mGroupProfilePic.frame.height) + CGFloat(self.mMembersHolderView.frame.height))
    }
    
    
    func getGroupMembers(){
        // get memebers
        let groupAsyncHttpClient = GroupAsyncHttpClient()
        self.showUIActivityIndicator()
        groupAsyncHttpClient.getGroupMembers(userIdStr: self.mUserIdStr, groupIdStr: String(describing: self.mGroupId!), respHandler: {
            (statusCode, resp) in
            self.showUIActivityIndicator()
            if let statusCode: Int = statusCode {
                let json = JSON(resp.value!)
                if(statusCode ==  200) {
                    self.mUserContainer.populateUser(json["result"])
                    self.createMembersHolderStackView()
                }else {
                    self.showAlertMsg(json["error"].string!)
                }
            }else {
                self.showAlertMsg("error creating event")
            }
        })

    }
    
    
    
}

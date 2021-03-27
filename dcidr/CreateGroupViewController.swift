//
//  CreateGroupViewController.swift
//  dcidr
//
//  Created by John Smith on 12/29/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import ImagePicker
class CreateGroupViewController: BaseViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, ImagePickerDelegate {
    
    
    
    var mEventType: String? = nil
    @IBOutlet weak var mGroupProfilePicImageView: UIImageView!
    @IBOutlet weak var mFriendsHolderScrollView: UIScrollView!
    @IBOutlet weak var mFriendPickerSearchBar: UISearchBar!
    @IBOutlet weak var mFriendPickerDialogView: UIView!
    var mSelectedFriendsArray: Array<Any>!
    var mFriendsHolderStackView: UIStackView!
    fileprivate var mArraySearchHolder: Array<Any>!
    var mUserContainer: UserContainer!
    var mGroupContainer: GroupContainer!
    fileprivate let mUserIdStr: String = DcidrApplication.getInstance().getUser().getUserIdStr()

    @IBOutlet weak var mGroupNameTextEdit: UITextField!
    @IBOutlet weak var mFriendPickerTableView: UITableView!
    @IBAction func onCancelButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
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
    
    override func initViewController(){
        self.mFriendPickerSearchBar.delegate = self
        self.mFriendPickerTableView.delegate = self
        self.mFriendPickerTableView.dataSource = self
        
        // set tableview selection to false
        self.mFriendPickerTableView.allowsSelection = false
        
        // set action in groupProfilePicImageView 
        self.mGroupProfilePicImageView.isUserInteractionEnabled = true
        self.mGroupProfilePicImageView.image = UIImage(named: "user_default_icon")
        self.mGroupProfilePicImageView.layer.borderWidth = 0
        self.mGroupProfilePicImageView.layer.cornerRadius = self.mGroupProfilePicImageView.frame.height / 2
        self.mGroupProfilePicImageView.clipsToBounds = true
        self.mGroupProfilePicImageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
        self.mGroupProfilePicImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreateGroupViewController.onGroupProfilePicClicked)))

        
        // make friendpicker view rounded and shadowish
        self.mFriendPickerDialogView.layer.cornerRadius = 5
        //self.mFriendPickerDialogView.layer.shadowColor = UIColor.gray.cgColor
        //self.mFriendPickerDialogView.layer.shadowOpacity = 0.5
        //self.mFriendPickerDialogView.layer.shadowOffset = CGSize.zero
        //self.mFriendPickerDialogView.layer.shadowRadius = 5
        //self.mFriendPickerDialogView.layer.shadowPath = UIBezierPath(rect: self.mFriendPickerDialogView.bounds).cgPath
        //self.mFriendPickerDialogView.layer.shouldRasterize = true
        
        
        self.mArraySearchHolder = Array<Any>()
        self.mUserContainer = UserContainer()
        self.mGroupContainer = GroupContainer()
        self.mSelectedFriendsArray = Array<Any>()
        self.createFriendsHolderStackView()

    }
    
    func onGroupProfilePicClicked() {
        let imagePickerController = ImagePickerController()
        imagePickerController.imageLimit = 1
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        self.mGroupProfilePicImageView.image = images[0]
        self.dismiss(animated: true, completion: nil)
    }
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
    func createFriendsHolderStackView() {
        self.mFriendsHolderStackView = UIStackView()
        self.mFriendsHolderStackView.translatesAutoresizingMaskIntoConstraints = false
        self.mFriendsHolderStackView.axis = .vertical
        self.mFriendsHolderScrollView.addSubview(self.mFriendsHolderStackView)
        self.mFriendsHolderScrollView.addConstraint(NSLayoutConstraint(item: self.mFriendsHolderStackView, attribute: .leading, relatedBy: .equal, toItem: self.mFriendsHolderScrollView, attribute: .leading, multiplier: 1, constant: 0))
        self.mFriendsHolderScrollView.addConstraint(NSLayoutConstraint(item: self.mFriendsHolderStackView, attribute: .trailing, relatedBy: .equal, toItem: self.mFriendsHolderScrollView, attribute: .trailing, multiplier: 1, constant: 0))
        self.mFriendsHolderScrollView.addConstraint(NSLayoutConstraint(item: self.mFriendsHolderStackView, attribute: .top, relatedBy: .equal, toItem: self.mFriendsHolderScrollView, attribute: .top, multiplier: 1, constant: 0))
        self.mFriendsHolderScrollView.addConstraint(NSLayoutConstraint(item: self.mFriendsHolderStackView, attribute: .centerX, relatedBy: .equal, toItem: self.mFriendsHolderScrollView, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            // when orientation changes, scrollview content size resets back to normal, so we need to set it here.
            self.mFriendsHolderScrollView.contentSize = CGSize(width: CGFloat(self.mFriendsHolderScrollView.frame.width), height: CGFloat(self.mFriendsHolderStackView.subviews.count * 50))
        };
    }
    
    @IBAction func onFriendPickerCancelButtonClicked(_ sender: Any) {
        self.mFriendPickerDialogView.isHidden = true

    }
    @IBAction func onFriendPickerAddButtonClicked(_ sender: Any) {
        
        self.mFriendPickerDialogView.isHidden = true
        
        // remove stackview from it's superview and re-add it
        self.mFriendsHolderStackView.removeFromSuperview()
        self.createFriendsHolderStackView()

        // add all selected items to array
        let userArray = Array(self.mUserContainer.getUserList())
        for (index, item) in userArray.enumerated()  {
            if (item.getIsSelected()) {
                let v = CreateGroupSelectedFriendsCustomView()
                v.addConstraint(NSLayoutConstraint(item: v, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 50))
                v.userName.text = item.getUserName()
                v.userProfilePic.layer.borderWidth = 0
                v.userProfilePic.layer.cornerRadius = v.userProfilePic.frame.height / 2
                v.userProfilePic.clipsToBounds = true
                
                // use button properties for setting type of object and array index for later use
                v.removeButton.tag = index
                v.removeButton.accessibilityHint = "user"
                v.removeButton.addTarget(self, action: #selector(CreateGroupViewController.onRemoveFriendButtonClicked), for: UIControlEvents.touchUpInside)
                if(item.getUserProfilePicData() != nil) {
                    v.userProfilePic.image = UIImage(data: item.getUserProfilePicData()!)
                }
                self.mFriendsHolderStackView.addArrangedSubview(v)
            }else {
                // remove if not selected
                self.mUserContainer.removeUser(userArray[index])
            }
        }
        
        let groupArray = Array(self.mGroupContainer.getGroupList(GroupContainer.TypeOfResult.ALL))
        for (index, item) in groupArray.enumerated()   {
            if (item.getIsSelected()) {
                let v = CreateGroupSelectedFriendsCustomView()
                v.addConstraint(NSLayoutConstraint(item: v, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 50))
                v.userName.text = item.groupName
                v.userProfilePic.layer.borderWidth = 0
                v.userProfilePic.layer.cornerRadius = v.userProfilePic.frame.height / 2
                v.userProfilePic.clipsToBounds = true
                
                // use button properties for setting type of object and array index for later use
                v.removeButton.tag = index
                v.removeButton.accessibilityHint = "group"
                v.removeButton.addTarget(self, action: #selector(CreateGroupViewController.onRemoveFriendButtonClicked), for: UIControlEvents.touchUpInside)
                if(item.groupProfilePicData != nil) {
                    v.userProfilePic.image = UIImage(data: item.groupProfilePicData!)
                }
                self.mFriendsHolderStackView.addArrangedSubview(v)
            }else {
                // remove if not selected
                self.mGroupContainer.removeGroup(groupArray[index])
            }
        }
        
        self.mFriendsHolderScrollView.contentSize = CGSize(width: CGFloat(self.mFriendsHolderScrollView.frame.width), height: CGFloat(self.mFriendsHolderStackView.subviews.count * 50))
    }
    
    func onRemoveFriendButtonClicked(sender: UIButton) {
        // check if accessibilityHint is user or group and use sender.tag for index
        if (sender.accessibilityHint == "user") {
            self.mUserContainer.getUserList()[sender.tag].setIsSelected(false)
        }
        if (sender.accessibilityHint == "group") {
            self.mGroupContainer.getGroupList(GroupContainer.TypeOfResult.ALL)[sender.tag].setIsSelected(false)
        }
        // reload data to refresh previously created list. if friend is removed from stackview, and if list view had it selected, we need to refresh
        // the tableview for update
        self.mFriendPickerTableView.reloadData()
        self.onFriendPickerAddButtonClicked(sender)
    }
    
    @IBAction func onAddFriendButtonClicked(_ sender: Any) {
        self.mFriendPickerDialogView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // remove non-selected items
        for item in self.mUserContainer.getUserList()  {
            if (!item.getIsSelected()) {
                self.mUserContainer.removeUser(item)
            }
        }
        
        for item in self.mGroupContainer.getGroupList(GroupContainer.TypeOfResult.ALL) {
            if(!item.getIsSelected()) {
                self.mGroupContainer.removeGroup(item)
            }
        }
        
        self.mArraySearchHolder.removeAll()
        if (searchText != "") {
            // get friends
            let userAsyncHttpClient = UserAsyncHttpClient()
            userAsyncHttpClient.getActiveFriendsByQueryText(self.mUserIdStr, queryText: searchText.lowercased(), offset: 0, limit: 1000000, respHandler: { (statusCode, resp) in
                if let statusCode: Int = statusCode {
                    let json = JSON(resp.value!)
                    if(statusCode ==  200) {
                        // populat user container
                        self.mUserContainer.populateUser(json["result"])
                        for item in self.mUserContainer.getUserList() {
                            self.mArraySearchHolder.append(item)
                        }
                        let groupAsyncHttpClient = GroupAsyncHttpClient()
                        groupAsyncHttpClient.getGroupsByQueryText(self.mUserIdStr, queryText: searchText.lowercased(), offset: 0, limit: 1000000, respHandler: { (statusCode, resp) in
                            if let statusCode: Int = statusCode {
                                let json = JSON(resp.value!)
                                if(statusCode ==  200) {
                                    // populate group container 
                                    self.mGroupContainer.populateGroup(json["result"])
                                    for item in self.mGroupContainer.getGroupList(GroupContainer.TypeOfResult.ALL) {
                                        self.mArraySearchHolder.append(item)
                                    }
                                    self.mFriendPickerTableView.reloadData()
                                }else {
                                    self.showAlertMsg(json["error"].string!)
                                }
                            }else {
                                self.showAlertMsg("error getting groups")
                            }
                        })
                    }else {
                        self.showAlertMsg(json["error"].string!)
                    }
                }else {
                    self.showAlertMsg("error getting friends")
                }
            })
        }else {
            self.mFriendPickerTableView.reloadData()
        }
    }
    
    @IBAction func onCreateGroupButtonClicked(_ sender: UIBarButtonItem) {
        
        if (self.mGroupNameTextEdit.text?.isEmpty)! {
            self.showAlertMsg("group name can not be empty")
            return
        }
        if(self.mUserContainer.getUserIds().count == 0 && self.mGroupContainer.getGroupIds().count == 0) {
            self.showAlertMsg("at-least one user of group must be selected")
            return
        }
        
        // create basegroup object
        let baseGroup = BaseGroup()
        baseGroup.groupName = self.mGroupNameTextEdit.text!
        baseGroup.groupProfilePicBase64Str = Utils.convertImageToBase64(image: self.mGroupProfilePicImageView.image!)
        let groupAsyncHttpClient = GroupAsyncHttpClient()
        
        // add current user into userContainer
        self.mUserContainer.addUser(DcidrApplication.getInstance().getUser())
        
        groupAsyncHttpClient.createGroup(userIdStr: self.mUserIdStr, baseGroup: baseGroup, userContainer: self.mUserContainer, groupContainer: self.mGroupContainer, respHandler: { (statusCode, resp) in
            if let statusCode: Int = statusCode {
                if let resp = resp.value {
                    let json = JSON(resp)
                    if(statusCode ==  201) {
                        // populate base group with newly created groupId 
                        baseGroup.groupId = json["groupId"].int64Value
                        baseGroup.groupLastModifiedTime = Utils.currentTimeMillis()
                        DcidrApplication.getInstance().getGlobalGroupContainer().populateGroup([JSON(baseGroup.getGroupMapForLocal())])
                        // go to new base event page
                        let newBaseEventViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "NewBaseEventViewController") as! NewBaseEventViewController
                        newBaseEventViewCtr.mGroupId = baseGroup.groupId
                        newBaseEventViewCtr.mEventType = self.mEventType
                        self.present(newBaseEventViewCtr, animated: true, completion: nil)
                    }else {
                        self.showAlertMsg(json["error"].string!)
                    }
                }else {
                    self.showAlertMsg("error creating group")
                }
            }else {
                self.showAlertMsg("error creating group")
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // launch event details view controller
    }
    
    
    // onNoOfRows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mArraySearchHolder.count
    }
    
    // onView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendPickerTableViewCell", for: indexPath) as! FriendPickerTableViewCell
        cell.setCellData(self, arrayList: self.mArraySearchHolder)
        return cell.getCellView(indexPath: indexPath)
    }
    
    // onScroll
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
}

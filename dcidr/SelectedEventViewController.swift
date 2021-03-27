//
//  SelectedEventViewController.swift
//  dcidr
//
//  Created by John Smith on 1/24/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import EventKit
class SelectedEventViewController : BaseViewController {
    
    var mGroupId: Int64? = nil
    var mEventId: Int64? = nil
    var mParentEventId: Int64? = nil
    fileprivate var mBaseEvent: BaseEvent!
    fileprivate var eventStore : EKEventStore!
    fileprivate let mUserIdStr : String = DcidrApplication.getInstance().getUser().getUserIdStr()

    @IBOutlet weak var mSelectedEventScrollView: UIScrollView!
    @IBOutlet weak var mUserEventStatusStackView: UIStackView!
    @IBOutlet weak var mNavigationBar: UINavigationBar!
    
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
    
    @IBAction func onPushToCalendarClicked(_ sender: UIButton) {
        
        let event = EKEvent(eventStore: self.eventStore)
        
        event.title = self.mBaseEvent.getEventName()
        event.startDate = NSDate(timeIntervalSince1970: TimeInterval(self.mBaseEvent.getStartTime())) as Date
        event.endDate = NSDate(timeIntervalSince1970: TimeInterval(self.mBaseEvent.getEndTime())) as Date
        event.notes = self.mBaseEvent.getEventNotes()
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        
        do {
            try self.eventStore.save(event, span: EKSpan.thisEvent)
            self.showAlertMsg("activity pushed into calendar")

        } catch  {
            self.showAlertMsg("error pushing activity into calendar")
        }
        
    }
    
    @IBAction func onCancelButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined: break
            // This happens on first-run
            //requestAccessToCalendar()
        case EKAuthorizationStatus.authorized: break
            // Things are in line with being able to show the calendars in the table view
            //loadCalendars()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied: break
            // We need to help them give us permission
            //
            //needPermissionView.fadeIn()
        }
    }
    
    override func initViewController(){
        
        self.eventStore = EKEventStore()
        self.checkCalendarAuthorizationStatus()
        if (self.mGroupId != nil) {
            if (self.mParentEventId != nil) {
                self.mBaseEvent = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId!)!.getEventContainer().getBaseEvent(self.mParentEventId!)
                self.mNavigationBar.topItem!.title = self.mBaseEvent.getEventName()
                self.populateUserData()
            }else {
                showAlertMsg("event id is nil")
            }
        }else {
            showAlertMsg("group id is nil")
        }

        
        
    }

    func populateUserData() {
        // check if user data is already there in data structure
//        if self.mBaseEvent.getUserEventStatusContainer().getUserEventStatusArray().count > 0 {
//            self.displayUserData()
//            return
//        }
        self.showUIActivityIndicator()
        let groupAsyncHttpClient = GroupAsyncHttpClient()
        groupAsyncHttpClient.getGroupMembers(userIdStr: self.mUserIdStr, groupIdStr: String(describing: self.mGroupId!)) { (statusCode, resp) in
                self.stopUIActivityIndicator()
                if let statusCode = statusCode {
                    if(statusCode == 200){
                        if let respValue = resp.value {
                            let json = JSON(respValue)
                            print(json["result"])
                            for i in json["result"].array! {
                                print(i)
                                self.mBaseEvent.getUserEventStatusContainer().getUserEventStatusObj(userId: i["userId"].int64Value)!.getUserObj().populateMe(i)
                            }
                            self.displayUserData()
                        }else {
                            self.showAlertMsg("error getting data from server")
                        }
                    }else {
                        if let respValue = resp.value {
                            let json = JSON(respValue)
                            self.showAlertMsg(json["error"].stringValue)
                        }else {
                            self.showAlertMsg("error getting user info")
                        }
                    }
                }else {
                    self.showAlertMsg("error connecting to server")
                }
            }
        
    }
    func displayUserData() {
        var index = 0
        for userEventStatus in self.mBaseEvent.getUserEventStatusContainer().getUserEventStatusArray() {
            let cv: EventStatusDetailsCustomView = EventStatusDetailsCustomView()
            cv.userName.text = userEventStatus.getUserObj().getUserName()
            if let data = userEventStatus.getUserObj().getUserProfilePicData() {
                cv.userProfilePic.image = self.resizeImage(UIImage(data: data)!, newWidth : 100)
            }else {
                userEventStatus.getUserObj().setUserProfilePicFetchDoneCb({ (imageData : Data?) in
                    cv.userProfilePic.image = self.resizeImage(UIImage(data: imageData!)!, newWidth : 100)
                })
            }
            
            
            if(userEventStatus.getEventStatusType() == UserEventStatus.EventStatusType.ACCEPTED) {
                cv.userEventStatus.backgroundColor = UIColor(hex: Colors.md_green_400)
            }else if (userEventStatus.getEventStatusType() == UserEventStatus.EventStatusType.DECLINED){
                cv.userEventStatus.backgroundColor = UIColor(hex: Colors.md_red_400)
            }else {
                cv.userEventStatus.backgroundColor = UIColor(hex: Colors.md_orange_400)
            }
            
            
            cv.userBuzzButton.tag = index
            cv.userBuzzButton.addTarget(self, action: #selector(onBuzzButtonClicked), for: .touchUpInside)

            cv.addConstraint(NSLayoutConstraint(item: cv, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 50))
            self.mUserEventStatusStackView.addArrangedSubview(cv)
            index += 1
        }
        
        
    }
    
    func onBuzzButtonClicked(sender: UIButton) {
        let userEventStatus = self.mBaseEvent.getUserEventStatusContainer().getUserEventStatusArray()[sender.tag]
        self.showUIActivityIndicator()
        let eventAsyncHttpClient = EventAsyncHttpClient()
        eventAsyncHttpClient.buzzUser(self.mUserIdStr, groupIdStr: String(describing: self.mGroupId!), eventIdStr: self.mBaseEvent.getEventIdStr(), parentEventIdStr: String(describing: self.mParentEventId), buzzUserIdStr: userEventStatus.getUserObj().getUserIdStr()) { (statusCode, resp) in
            self.stopUIActivityIndicator()
            if let statusCode = statusCode {
                if(statusCode == 200){
                    self.showAlertMsg("you just buzzed \(userEventStatus.getUserObj().getUserName())")
                }else {
                    if let respValue = resp.value {
                        let json = JSON(respValue)
                        self.showAlertMsg(json["error"].stringValue)
                    }else {
                        self.showAlertMsg("error buzzing user")
                    }
                }
            }else {
                self.showAlertMsg("error connecting to server")
            }
        }

    }
}

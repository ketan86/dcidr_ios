//
//  EventTimelineTableViewCell.swift
//  dcidr
//
//  Created by John Smith on 1/19/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Agrume
class EventTimelineTableViewCell : UITableViewCell {
    
    @IBOutlet weak var mEventTimeLineCellView: UIView!
    @IBOutlet weak var mEventName: UILabel!
    @IBOutlet weak var mEventPlace: UILabel!
    
    @IBOutlet weak var mEventPic: UIImageView!
    @IBOutlet weak var mEventStatusLabel: UILabel!
    @IBOutlet weak var mAcceptedMembersCount: UIButton!
    @IBOutlet weak var mAcceptEventButton: UIButton!
    @IBOutlet weak var mDeclineEventButton: UIButton!
    @IBOutlet weak var mEventNotes: UILabel!
    @IBOutlet weak var mCreatedByUserName: UILabel!
    fileprivate var mBaseViewController: BaseViewController!
    fileprivate var mArrayList: Array<BaseEvent>!
    fileprivate var mBaseEvent : BaseEvent!
    fileprivate var mIndexPath: IndexPath!
    @IBOutlet weak var mGoogleMapImageView: UIImageView!
    
    @IBOutlet weak var mEventDecidedByTimeLeft: UILabel!
    @IBAction func onAcceptedMembersCountClicked(_ sender: Any) {
        self.mAcceptEventButton.isHidden = false
        self.mDeclineEventButton.isHidden = false
    }
    
    @IBAction func onDecineEventButtonClicked(_ sender: Any) {
        self.mDeclineEventButton.isHidden = true
        self.mAcceptEventButton.isHidden = true
        self.showEventStatusConfirmationDialog("decline", eventStatusType: UserEventStatus.EventStatusType.DECLINED)
    }
    
    @IBAction func onAcceptEventButtonClicked(_ sender: Any) {
        self.mDeclineEventButton.isHidden = true
        self.mAcceptEventButton.isHidden = true
        self.showEventStatusConfirmationDialog("accept", eventStatusType: UserEventStatus.EventStatusType.ACCEPTED)

    }
    
    func showEventStatusConfirmationDialog(_ action: String, eventStatusType: UserEventStatus.EventStatusType) {
        self.mBaseViewController.showAlertMsgWithOptions("Activity Status", textMsg: "Do you want to \(action) the activity?", okCb: {
            (result : UIAlertAction) -> Void in
            let userEventStatusContainer = self.mBaseEvent.getUserEventStatusContainer()
            let currentUserEventStatusObj = userEventStatusContainer.getCurrentUserEventStatusObj()
            let currentUserStatus = currentUserEventStatusObj!.getEventStatusType()
            if (currentUserStatus == eventStatusType) {
                return;
            }
            currentUserEventStatusObj!.setEventStatusType(eventStatusType)
            let eventAsyncHttpClient = EventAsyncHttpClient()
            eventAsyncHttpClient.updateUserEventStatus(self.mBaseEvent.getParentEventIdStr(),
                                                       parentEventTypeStr: self.mBaseEvent.getParentEventTypeStr(),
                                                       userEventStatus: currentUserEventStatusObj!, respHandler: {
                                                        (statusCode, resp) in
                                                        if let statusCode = statusCode {
                                                            if(statusCode == 200){
                                                                let statusDict = userEventStatusContainer.getUserToStatusDict()
                                                                self.mAcceptedMembersCount.setTitle(String(describing: statusDict[UserEventStatus.EventStatusType.ACCEPTED]!), for: .normal)
                                                                
                                                                
                            
                                                                if (eventStatusType == UserEventStatus.EventStatusType.ACCEPTED) {
                                                                    self.mEventStatusLabel.text = String(describing: eventStatusType)
                                                                    self.mEventStatusLabel.backgroundColor = UIColor(hex: Colors.md_green_400)
                                                                } else if (eventStatusType == UserEventStatus.EventStatusType.DECLINED) {
                                                                    self.mEventStatusLabel.text = String(describing: eventStatusType)
                                                                    self.mEventStatusLabel.backgroundColor = UIColor(hex: Colors.md_red_400)
                                                                } else {
                                                                    self.mEventStatusLabel.text = String(describing: eventStatusType)
                                                                    self.mEventStatusLabel.backgroundColor = UIColor(hex: Colors.md_orange_400)
                                                                }
                                                                
                                                                
                                                                let eventTimelineViewController = self.mBaseViewController as! EventTimelineViewControlller
                                                                
                                                                let eventTimelineTableView  = eventTimelineViewController.mEventTimelineTableView
                                                                
                                                                
                                                                // loop through tableview row and set other events as declined
                                                                for section in 0..<eventTimelineTableView!.numberOfSections {
                                                                    for row in 0..<eventTimelineTableView!.numberOfRows(inSection: section) {
                                                                        if(row != self.mIndexPath.row) {
                                                                            let baseEvent: BaseEvent = self.mArrayList[row]
                                                                            for  userEventStatus in baseEvent.getUserEventStatusContainer().getUserEventStatusArray() {
                                                                                if (userEventStatus === baseEvent.getUserEventStatusContainer().getCurrentUserEventStatusObj()!) {
                                                                                    userEventStatus.setEventStatusType(UserEventStatus.EventStatusType.DECLINED)
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                for indexPath in eventTimelineTableView!.indexPathsForVisibleRows! {
                                                                    if(indexPath.row != self.mIndexPath.row) {
                                                                        // if view is not loaded by tableView, it will be nil and we do not care about non-loaded views
                                                                        if let eventStatusForOtherEvents = eventTimelineTableView!.subviews[indexPath.row].viewWithTag(1) as? UILabel {
                                                                            
                                                                            if(eventStatusForOtherEvents.text != String(describing: UserEventStatus.EventStatusType.DECLINED)) {
                                                                                eventStatusForOtherEvents.text = String(describing: UserEventStatus.EventStatusType.DECLINED)
                                                                                eventStatusForOtherEvents.backgroundColor = UIColor(hex: Colors.md_red_400)
                                                                                
                                                                            }

                                                                        }
                                                                        // if view is not loaded by tableView, it will be nil and we do not care about non-loaded views
                                                                        if let acceptedMembersCountForOtherEvents: UIButton = eventTimelineTableView!.subviews[indexPath.row].viewWithTag(2) as? UIButton {

                                                                            let baseEvent: BaseEvent = self.mArrayList[indexPath.row]
                                                    
                                                                            let statusDictForOtherEvents = baseEvent.getUserEventStatusContainer().getUserToStatusDict()
                                                                            acceptedMembersCountForOtherEvents.setTitle(String(describing: statusDictForOtherEvents[UserEventStatus.EventStatusType.ACCEPTED]), for: .normal)
                                                                        }
                                                                    
                                                                    }
                                                                }
                                                                
                                                                eventTimelineTableView!.reloadData()
                                                                eventTimelineTableView!.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.none, animated: true)
                                                            
                                                                
                                                                
                                                            }else {
                                                                if let respValue = resp.value {
                                                                    let json = JSON(respValue)
                                                                    self.mBaseViewController.showAlertMsg(json["error"].stringValue)
                                                                }else {
                                                                    self.mBaseViewController.showAlertMsg("error getting data from server")
                                                                }
                                                            }
                                                        }else {
                                                            self.mBaseViewController.showAlertMsg("error connecting to server")
                                                        }
            
            })
            
        }, cancelCb: {
            (result : UIAlertAction) -> Void in
            // nothing to do
        })
        
        
    }
    
    func setCellData(_ baseViewController: BaseViewController, arrayList: Array<BaseEvent>){
        self.mBaseViewController = baseViewController
        self.mArrayList = arrayList
    }
    
    func getCellView(indexPath: IndexPath) -> EventTimelineTableViewCell {
        
        // tag views
        self.mEventStatusLabel.tag = 1
        self.mAcceptedMembersCount.tag = 2
        
        // set current indexPath
        self.mIndexPath = indexPath
        
        // make buttons round
        self.mAcceptEventButton.layer.borderWidth = 0
        self.mAcceptEventButton.layer.cornerRadius = self.mAcceptEventButton.frame.height / 2
        
        self.mDeclineEventButton.layer.borderWidth = 0
        self.mDeclineEventButton.layer.cornerRadius = self.mDeclineEventButton.frame.height / 2
        
        self.mAcceptedMembersCount.layer.borderWidth = 0
        self.mAcceptedMembersCount.layer.cornerRadius = self.mAcceptedMembersCount.frame.height / 2
        
        // make border around image
        self.mEventPic.layer.borderWidth = 1
        self.mEventPic.layer.borderColor = UIColor(hex: Colors.md_gray_200).cgColor
        
        // make border around view cell
        self.mEventTimeLineCellView.layer.borderWidth = 1
        self.mEventTimeLineCellView.layer.borderColor = UIColor(hex: Colors.md_gray_200).cgColor
        
        
        // set eventStatusLabel text color to white
        self.mEventStatusLabel.textColor = UIColor.white
        
        // set AcceptedMemebersCount to 0 by default
        self.mAcceptedMembersCount.setTitle("0", for: .normal)
        
        self.mBaseEvent = self.mArrayList[indexPath.row]
        
        self.mEventName.text  = self.mBaseEvent.getEventName()
        
        let userEventStatusContainer = self.mBaseEvent.getUserEventStatusContainer()
        let statusDict = userEventStatusContainer.getUserToStatusDict()
        self.mAcceptedMembersCount.setTitle(String(describing: statusDict[UserEventStatus.EventStatusType.ACCEPTED]!), for: .normal)
        self.mEventNotes.text  = self.mBaseEvent.getEventNotes()
        self.mCreatedByUserName.text  = self.mBaseEvent.getCreatedByName()
        self.mEventPic.image = UIImage()

        if(self.mBaseEvent.getEventProfilePicData() == nil) {
            self.mBaseEvent.seEventProfilePicFetchDoneCb({ (imageData : Data) in
                self.mEventPic.image = self.mBaseViewController.resizeImage(UIImage(data: imageData)!, newWidth : 500)
            })
        }else {
            if let data = self.mBaseEvent.getEventProfilePicData() {
                self.mEventPic.image = self.mBaseViewController.resizeImage(UIImage(data: data)!, newWidth : 500)
            }
        }
        
        self.mBaseEvent.setViewWithTimeLeft(futureEpochTimeInMilliSecs: self.mBaseEvent.getDecidedTime(), label: self.mEventDecidedByTimeLeft)
        
        // set accept and decline status of the event
        let userEventStatus = userEventStatusContainer.getCurrentUserEventStatusObj()
        if (userEventStatus != nil) {
            if (userEventStatus!.getEventStatusType() == UserEventStatus.EventStatusType.ACCEPTED) {
                self.mEventStatusLabel.text = String(describing: userEventStatus!.getEventStatusType())
                self.mEventStatusLabel.backgroundColor = UIColor(hex: Colors.md_green_400)
            } else if (userEventStatus!.getEventStatusType() == UserEventStatus.EventStatusType.DECLINED) {
                self.mEventStatusLabel.text = String(describing: userEventStatus!.getEventStatusType())
                self.mEventStatusLabel.backgroundColor = UIColor(hex: Colors.md_red_400)
            } else {
                self.mEventStatusLabel.text = String(describing: userEventStatus!.getEventStatusType())
                self.mEventStatusLabel.backgroundColor = UIColor(hex: Colors.md_orange_400)
            }
        }
        
        // load static map view
        self.loadGoogleMap()
        
        
        // set tap gesture on eventStatus label
        self.mEventStatusLabel.isUserInteractionEnabled = true
        self.mEventStatusLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventTimelineTableViewCell.onEventClicked)))
        
        // set tap gesture on eventName label 
        self.mEventName.isUserInteractionEnabled = true
        self.mEventName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventTimelineTableViewCell.onEventClicked)))
        
        // set tap gesture on eventPlace label
        self.mEventPlace.isUserInteractionEnabled = true
        self.mEventPlace.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventTimelineTableViewCell.onEventClicked)))

        // set tap gesture on mCreatedByUserName label
        self.mCreatedByUserName.isUserInteractionEnabled = true
        self.mCreatedByUserName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventTimelineTableViewCell.onEventClicked)))

        // set tap gesture on mEventNotes label
        self.mEventNotes.isUserInteractionEnabled = true
        self.mEventNotes.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventTimelineTableViewCell.onEventClicked)))
        
        
        // set tap gesture on mGoogleMapView label
        self.mGoogleMapImageView.isUserInteractionEnabled = true
        self.mGoogleMapImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventTimelineTableViewCell.onEventMapClicked)))
        
        
        // set tap gesture on mEventPic label
        self.mEventPic.isUserInteractionEnabled = true
        self.mEventPic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventTimelineTableViewCell.onEventPicClicked)))
        return self
    }
    
    
    func onEventPicClicked(sender : UIGestureRecognizer) {
        
        if let data = self.mBaseEvent.getEventProfilePicData() {
            let agrume = Agrume(image: UIImage(data: data)!, backgroundColor: .white)
            agrume.showFrom(self.mBaseViewController)
        }
        
    }
    	
    func onEventMapClicked(sender: UIGestureRecognizer)  {
        // launch map view controller
        let mapViewCtr = self.mBaseViewController.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        mapViewCtr.mLatitude = self.mBaseEvent.getLocationCoordinatesPoints()!.getLatitude()
        mapViewCtr.mLongitude = self.mBaseEvent.getLocationCoordinatesPoints()!.getLongitude()
        mapViewCtr.mMarkerTitle = self.mBaseEvent.getEventName()
        mapViewCtr.mMarkerSnippet = "Created by " + self.mBaseEvent.getCreatedByName()!
        self.mBaseViewController.present(mapViewCtr, animated: true, completion: nil)
    }
    
    
    func onEventClicked(sender: UIGestureRecognizer)  {
        
        let eventTimelineViewController = self.mBaseViewController as! EventTimelineViewControlller
        
        //using sender, we can get the point in respect to the table view
        let tapLocation = sender.location(in: eventTimelineViewController.mEventTimelineTableView)
        
        //using the tapLocation, we retrieve the corresponding indexPath
        let indexPath = eventTimelineViewController.mEventTimelineTableView.indexPathForRow(at: tapLocation)!
        
        eventTimelineViewController.didSelectRowAt(indexPath: indexPath)
    }
    
    
    func loadGoogleMap() {
        // set google static image map
        // TODO make lib instead of direct use
        print(self.mBaseEvent.getLocationCoordinatesPoints()!.getLongitude())
        let staticMapUrl: String = "http://maps.google.com/maps/api/staticmap?markers=color:blue|\(self.mBaseEvent.getLocationCoordinatesPoints()!.getLatitude()),\(self.mBaseEvent.getLocationCoordinatesPoints()!.getLongitude())&\("zoom=10&size=\(Int(self.mGoogleMapImageView.frame.width))x\(Int(self.mGoogleMapImageView.frame.height))")&sensor=true"
        let mapUrl = URL(string: staticMapUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        
        if let data = NSData(contentsOf: mapUrl!) {
            self.mGoogleMapImageView.image = UIImage(data: data as Data)
        }
    }
}

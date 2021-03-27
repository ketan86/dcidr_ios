//
//  NewBaseEventViewController.swift
//  dcidr
//
//  Created by John Smith on 2/9/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import DatePickerDialog
import GooglePlaces
import GooglePlacePicker
import SwiftyJSON
class NewBaseEventViewController:  BaseViewController {
    
    
    
    
    var mCaller: String? = nil
    var mGroupId: Int64? = nil
    var mEventId: Int64? = nil
    var mParentEventId: Int64? = -1
    var mEventType: String!
    var mParentEventType: String? = String(describing: BaseEvent.EventType.UNKNOWN)
    fileprivate var mParentEvent: BaseEvent? = nil
    fileprivate var mPlacesClient: GMSPlacesClient!
    fileprivate var mUserIdStr: String = DcidrApplication.getInstance().getUser().getUserIdStr()
    fileprivate var mPoints: Points!
    fileprivate var mBaseEvent: BaseEvent!
    @IBOutlet weak var mEventProfilePicScrollView: UIScrollView!
    
    @IBOutlet weak var mEventProfilePicStackView: UIStackView!
    @IBOutlet weak var mEventTypeTitle: UINavigationItem!
    @IBOutlet weak var mHeaderBarView: UIView!
    @IBOutlet weak var mEventEndDate: UIButton!
    @IBOutlet weak var mEventName: UITextField!
    @IBOutlet weak var mEventLocation: UIButton!
    @IBOutlet weak var mEventStartDate: UIButton!
    @IBOutlet weak var mEventStartTime: UIButton!
    @IBOutlet weak var mEventEndTime: UIButton!
    @IBOutlet weak var mEventCreationOptionsPopupView: UIView!
    @IBOutlet weak var mAllowDiffTypeOfEventCreationSwitch: UISwitch!
    
    @IBOutlet weak var mEventDecideByDate: UIButton!
    @IBOutlet weak var mAllowEventProposalSwitch: UISwitch!
  
    @IBOutlet weak var mEventNotes: UITextField!
    @IBOutlet weak var mEventDecideByTime: UIButton!
    @IBOutlet weak var mEventPlaceEditableSwitch: UISwitch!
    @IBOutlet weak var mEditableByOthersSwitch: UISwitch!
    @IBOutlet weak var mEventTimeEditableSwitch: UISwitch!
    
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
        
        self.mPlacesClient = GMSPlacesClient.shared()
        self.mPoints  = Points()
        
        if(self.mCaller == "NewBaseEventViewController") {
            self.mBaseEvent = DcidrApplication.getInstance().getGlobalHistoryContainer().getBaseGroup(self.mGroupId!)!.getEventContainer().getBaseEvent(self.mEventId!)
            self.mEventName.text = self.mBaseEvent.getEventName()
            self.mEventLocation.setTitle(self.mBaseEvent.getLocationName(), for: .normal)
            self.mEventStartDate.titleLabel!.text = Utils.epochToDateFromatted(epoch: self.mBaseEvent!.getStartTime(), format: "MM/dd/yyyy")
            self.mEventStartTime.titleLabel!.text = Utils.epochToDateFromatted(epoch: self.mBaseEvent!.getStartTime(), format: "HH:mm aa")
            self.mEventEndDate.titleLabel!.text = Utils.epochToDateFromatted(epoch: self.mBaseEvent!.getEndTime(), format: "MM/dd/yyyy")
            self.mEventEndTime.titleLabel!.text = Utils.epochToDateFromatted(epoch: self.mBaseEvent!.getEndTime(), format: "HH:mm aa")
            self.mEventDecideByDate.titleLabel!.text = Utils.epochToDateFromatted(epoch: self.mBaseEvent!.getDecideByTime(), format: "MM/dd/yyyy")
            self.mEventDecideByTime.titleLabel!.text = Utils.epochToDateFromatted(epoch: self.mBaseEvent!.getDecideByTime(), format: "HH:mm aa")
            self.mEventType = self.mBaseEvent.getEventTypeStr()
        }
        
        // if parentEventId is not -1, get the parent Event
        
        if(self.mParentEventId != -1) {
            self.mParentEvent = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId!)!.getEventContainer().getBaseEvent(self.mParentEventId!)
            let eventAttrMask = self.mParentEvent!.getEventAttributeMask()
            if(!eventAttrMask.isEventAttributeEditable(eventAttribute: BaseEvent.EventAttribute.ALLOW_EDITABLE_EVENT_LOCATION)) {
                self.mEventLocation.setTitle(self.mParentEvent?.getLocationName(), for: .normal)
                self.mEventLocation.isEnabled = false
            }
            
            
            if(!eventAttrMask.isEventAttributeEditable(eventAttribute: BaseEvent.EventAttribute.ALLOW_EDITABLE_EVENT_TIME)) {
                
                self.mEventStartDate.titleLabel!.text = Utils.epochToDateFromatted(epoch: self.mParentEvent!.getStartTime(), format: "MM/dd/yyyy")
                self.mEventStartDate.isEnabled = false
                
                
                self.mEventStartTime.titleLabel!.text = Utils.epochToDateFromatted(epoch: self.mParentEvent!.getStartTime(), format: "HH:mm aa")
                self.mEventStartTime.isEnabled = false
                
                self.mEventEndDate.titleLabel!.text = Utils.epochToDateFromatted(epoch: self.mParentEvent!.getEndTime(), format: "MM/dd/yyyy")
                self.mEventEndDate.isEnabled = false
                self.mEventEndTime.titleLabel!.text = Utils.epochToDateFromatted(epoch: self.mParentEvent!.getEndTime(), format: "HH:mm aa")
                self.mEventEndTime.isEnabled = false
                self.mEventDecideByDate.titleLabel!.text = Utils.epochToDateFromatted(epoch: self.mParentEvent!.getDecideByTime(), format: "MM/dd/yyyy")
                self.mEventStartDate.isEnabled = false
                self.mEventDecideByTime.titleLabel!.text = Utils.epochToDateFromatted(epoch: self.mParentEvent!.getDecideByTime(), format: "HH:mm aa")
                self.mEventDecideByTime.isEnabled = false
            }
        }
        
        self.mEventTypeTitle.title = self.mEventType

    }
    
    @IBAction func mEditableByOthersSwitchClicked(_ sender: UISwitch) {
        if (sender.isOn) {
            self.mEventPlaceEditableSwitch.isOn = true
            self.mEventTimeEditableSwitch.isOn = true
        }else {
            self.mEventPlaceEditableSwitch.isOn = false
            self.mEventTimeEditableSwitch.isOn = false
        }
    }
    
    @IBAction func onEventCreationOptionsButtonClicked(_ sender: UIButton) {
        if (self.mEventCreationOptionsPopupView.isHidden == true) {
            self.mEventCreationOptionsPopupView.isHidden = false
        }else {
            self.mEventCreationOptionsPopupView.isHidden = true
        }
    }
    
    @IBAction func onCancelButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onEventLocationClicked(_ sender: UIButton) {
        
        for v in self.mEventProfilePicStackView.subviews {
            self.mEventProfilePicStackView.removeArrangedSubview(v)
        }
        let center = CLLocationCoordinate2D(latitude: 37.788204, longitude: -122.411937)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePicker(config: config)
        
        placePicker.pickPlace(callback: {(place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                self.mEventLocation.setTitle(place.name, for: .normal)
                self.mPoints.setLatitude(place.coordinate.latitude)
                self.mPoints.setLongitude(place.coordinate.longitude)
                self.loadPhotosForPlace(placeID: place.placeID)
            }
            
            
            
        })
    }
    
    func loadPhotosForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                for photo in (photos?.results)! {
                    self.loadImageForMetadata(photoMetadata: photo)
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                let i = UIImageView()
                i.image = self.resizeImage(photo!, newWidth : 50)
                self.mEventProfilePicStackView.addArrangedSubview(i)
                print(self.mEventProfilePicStackView.subviews.count)
                self.mEventProfilePicScrollView.contentSize = CGSize(width: CGFloat(100000), height: CGFloat(self.mEventProfilePicScrollView.frame.height))
            }
        })
    }
    
    @IBAction func mEventStartDateOnClicked(_ sender: UIButton) {
        
        DatePickerDialog().show(title: "Pick Start Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if (date != nil) {
                // format date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.medium
                let convertedDate = dateFormatter.string(from: date!)
                self.mEventStartDate.setTitle(convertedDate, for: .normal)
            }
        }
        
    }
    @IBAction func mEventStartTimeOnClicked(_ sender: UIButton) {
        DatePickerDialog().show(title: "Pick Start Time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .time) {
            (date) -> Void in
            if (date != nil) {
                // format date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                let convertedDate = dateFormatter.string(from: date!)
                self.mEventStartTime.setTitle(convertedDate, for: .normal)
            }
        
        }
        
    }
    
    @IBAction func mEventEndDateOnClicked(_ sender: UIButton) {
        
        DatePickerDialog().show(title: "Pick End Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if (date != nil) {
                // format date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.medium
                let convertedDate = dateFormatter.string(from: date!)
                self.mEventEndDate.setTitle(convertedDate, for: .normal)
            }
        }
        
    }
    @IBAction func mEventEndTimeOnClicked(_ sender: UIButton) {
        DatePickerDialog().show(title: "Pick End Time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .time) {
            (date) -> Void in
            if (date != nil) {
                // format date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                let convertedDate = dateFormatter.string(from: date!)
                self.mEventEndTime.setTitle(convertedDate, for: .normal)
            }
            
        }
        
    }
    
    @IBAction func mEventDecideByDateOnClicked(_ sender: UIButton) {
        
        DatePickerDialog().show(title: "Pick Decide By Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if (date != nil) {
                // format date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.medium
                let convertedDate = dateFormatter.string(from: date!)
                self.mEventDecideByDate.setTitle(convertedDate, for: .normal)
            }
        }
        
    }
    @IBAction func mEventDecideByTimeOnClicked(_ sender: UIButton) {
        DatePickerDialog().show(title: "Pick Decide By Time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .time) {
            (date) -> Void in
            if (date != nil) {
                // format date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                let convertedDate = dateFormatter.string(from: date!)
                self.mEventDecideByTime.setTitle(convertedDate, for: .normal)
            }
            
        }
        
    }
    
    
    @IBAction func onCreateEventClicked(_ sender: UIBarButtonItem) {
        
        if(self.mEventName.text!.isEmpty) {
            self.showAlertMsg("evnet name can not be empty")
        }
        
        self.mBaseEvent = BaseEvent()
        let eventAttrMask = self.mBaseEvent.getEventAttributeMask()
        if(self.mAllowDiffTypeOfEventCreationSwitch.isOn) {
            eventAttrMask.setEventAttribute(eventAttribute: BaseEvent.EventAttribute.ALLOW_EDITABLE_DIFFERENT_EVENT_TYPES)
        }
        
        if(self.mEventPlaceEditableSwitch.isOn) {
            eventAttrMask.setEventAttribute(eventAttribute: BaseEvent.EventAttribute.ALLOW_EDITABLE_EVENT_LOCATION)
        }
        
        if(self.mEventTimeEditableSwitch.isOn) {
            eventAttrMask.setEventAttribute(eventAttribute: BaseEvent.EventAttribute.ALLOW_EDITABLE_EVENT_TIME)
        }
        
        if(self.mAllowEventProposalSwitch.isOn) {
            eventAttrMask.setEventAttribute(eventAttribute: BaseEvent.EventAttribute.ALLOW_EVENT_PROPOSAL)
        }

        
        self.mBaseEvent.setCreatedByName(DcidrApplication.getInstance().getUser().getUserName())
        self.mBaseEvent.setEventType(BaseEvent.EventType.enumFromString(self.mEventType)!)
        
        
        self.mBaseEvent.setParentEventId(self.mParentEventId!)
        
        
        
        if let pet = BaseEvent.EventType.enumFromString(self.mParentEventType!)  {
            self.mBaseEvent.setParentEventType(pet)
        }
        
        self.mBaseEvent.setEventLastModifiedTime(Utils.currentTimeMillis())
        self.mBaseEvent.setLocationName((self.mEventLocation.titleLabel?.text!)!)
        
        if let pe = self.mParentEvent {
            if(!pe.getEventAttributeMask().isEventAttributeEditable(eventAttribute: BaseEvent.EventAttribute.ALLOW_EDITABLE_EVENT_LOCATION)) {
                self.mBaseEvent.setLocationCoordinates((self.mParentEvent!.getLocationCoordinatesPoints()?.getLatitude())!, longitude: (self.mParentEvent!.getLocationCoordinatesPoints()?.getLongitude())!)
            }else{
                self.mBaseEvent.setLocationCoordinates(self.mPoints.getLatitude(), longitude: self.mPoints.getLongitude())
            }
        }
        
        self.mBaseEvent.setEventName(self.mEventName.text!)
        self.mBaseEvent.setEventNotes(self.mEventNotes.text!)
        self.mBaseEvent.setStartTime(Utils.convertDateTimeToEpoch(date: self.mEventStartDate.titleLabel!.text!, time: self.mEventStartTime.titleLabel!.text!, timeZone: TimeZone.current, format: "MM/dd/yyyy hh:mm a"))
        self.mBaseEvent.setEndTime(Utils.convertDateTimeToEpoch(date: self.mEventEndDate.titleLabel!.text!, time: self.mEventEndTime.titleLabel!.text!, timeZone: TimeZone.current, format: "MM/dd/yyyy hh:mm a"))
        self.mBaseEvent.setDecidedTime(Utils.convertDateTimeToEpoch(date: self.mEventDecideByDate.titleLabel!.text!, time: self.mEventDecideByTime.titleLabel!.text!, timeZone: TimeZone.current, format: "MM/dd/yyyy hh:mm a"))
        
        
        
        // send invitation
        let eventAsyncHttpClient = EventAsyncHttpClient()
        self.showUIActivityIndicator()
        eventAsyncHttpClient.createEvent(userIdStr: self.mUserIdStr, groupIdStr: String(describing: self.mGroupId!), baseEvent: self.mBaseEvent, respHandler: {
            (statusCode, resp) in
            self.showUIActivityIndicator()
            if let statusCode: Int = statusCode {
                let json = JSON(resp.value!)
                if(statusCode ==  201) {
                    self.mBaseEvent.setEventId(json["eventId"].int64Value);
                    
                    var event = self.mBaseEvent.getEventDataAsMap()
                    event["groupId"] = self.mGroupId
                    event["userId"] = self.mUserIdStr
                    
                    let eventJson = JSON(event)
                    
                    //JSONObject eventJsonObject = new JSONObject(mHikeEvent.getEventDataAsMap());
                    //eventJsonObject.put("groupId", mGroupIdStr);
                    //eventJsonObject.put("eventId", mHikeEvent.getEventIdStr());
                    //eventJsonObject.put("eventTypeId", BaseEvent.EventType.valueOf(mHikeEvent.getEventTypeStr()).getValue());
                    //eventJsonObject.put("userId", DcidrApplication.getInstance().getUser().getUserIdStr());
                    //eventJsonObject.put("groupLastModifiedTime", String.valueOf(System.currentTimeMillis()));
                    //Long groupId = Long.valueOf(mGroupIdStr).longValue();
                    let groupContainer = DcidrApplication.getInstance().getGlobalGroupContainer()
                    let baseGroup: BaseGroup = groupContainer.getBaseGroup(self.mGroupId!)!
                    if(self.mParentEvent != nil) {
                        baseGroup.incrementTotalEventCount()
                    }
                    baseGroup.groupLastModifiedTime = Utils.currentTimeMillis()
                    
                    groupContainer.refreshGroupList(GroupContainer.TypeOfResult.SCROLLED)
                    
                    let ec = baseGroup.getEventContainer()
                    
                    //                    JSONObject jsonUserEventObject = new JSONObject();
                    //                    jsonUserEventObject.put("userId", DcidrApplication.getInstance().getUser().getUserIdStr());
                    //                    jsonUserEventObject.put("eventId",  mHikeEvent.getEventIdStr());
                    //                    jsonUserEventObject.put("eventStatusTypeId",  1);
                    //
                    //                    UserEventStatusContainer userEventStatusContainer;
                    if (self.mParentEventId == -1) {
                        ec.populateEvent(eventJson)
                        //                        userEventStatusContainer = eventContainer.getEventMap().get(mHikeEvent.getEventId()).getUserEventStatusContainer();
                        //                        eventContainer.refreshEventList();
                        //                        userEventStatusContainer.setGroupId(groupId);
                        //                        userEventStatusContainer.populateMe(jsonUserEventObject);
                    }else {
                        ec.getBaseEvent(self.mParentEventId!)?.getChildEventsContainer().populateEvent(eventJson)
                        //ec.getBaseEvent(mHikeEvent.getParentEventId()).getChildEventsContainer().populateEvent(eventJsonObject);
                        //                        userEventStatusContainer = eventContainer.getEventMap().get(mHikeEvent.getParentEventId()).getChildEventsContainer().getEventMap().get(mHikeEvent.getEventId()).getUserEventStatusContainer();
                        //                        eventContainer.refreshEventList();
                        //                        userEventStatusContainer.setGroupId(groupId);
                        //                        userEventStatusContainer.populateMe(jsonUserEventObject);
                        //
                        //                        // set parent and all other child event status to declined
                        //                        UserEventStatusContainer parentUserEventStatusContainer = eventContainer.getEventMap().get(mHikeEvent.getParentEventId()).getUserEventStatusContainer();
                        //                        parentUserEventStatusContainer.getCurrentUserEventStatusObj().setEventStatusType(UserEventStatus.EventStatusType.DECLINED);
                        //                        for(BaseEvent childEvent : eventContainer.getEventMap().get(mHikeEvent.getParentEventId()).getChildEventsContainer().getEventList()) {
                        //                            childEvent.getUserEventStatusContainer().getCurrentUserEventStatusObj().setEventStatusType(UserEventStatus.EventStatusType.DECLINED);
                        //                        }
                    }
                    
                    
                    // go to main VC
                    let MainViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                    self.present(MainViewCtr, animated: true, completion: nil)
                    


                
                    
                }else {
                    self.showAlertMsg(json["error"].string!)
                }
            }else {
                self.showAlertMsg("error creating event")
            }
        })
        
        
        
        
    }
}

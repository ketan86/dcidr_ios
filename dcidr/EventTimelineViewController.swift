//
//  EventTimelineViewController.swift
//  dcidr
//
//  Created by John Smith on 1/19/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
class EventTimelineViewControlller: BaseViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, Fetchable {
    
    var mGroupId: Int64? = nil
    var mParentEventId: Int64? = nil
    var mParentEventType: String? = nil
    fileprivate var mBaseEvent: BaseEvent? = nil

    @IBOutlet weak var mProposeEventButton: UIBarButtonItem!
    @IBOutlet weak var mSendChweetButton: UIButton!
    fileprivate var mEventContainer : EventContainer!
    fileprivate var mAllEvents: Array<BaseEvent>!
    fileprivate var mChweetContainer: ChweetContainer!
    fileprivate var mEventAsyncHttpClient: EventAsyncHttpClient!
    fileprivate var mFetchHandler: FetchHandler!
    fileprivate let mUserIdStr : String = DcidrApplication.getInstance().getUser().getUserIdStr()
    @IBOutlet weak var mChweetCollectionView: UICollectionView!
    
    @IBOutlet weak var mEventTimelineTableView: UITableView!
    @IBAction func onCancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func handleInputDataDict(data: [String: Any]?) {
        
        if let dict = data {
            for (key,value) in dict {
                if(key == "eventId") {
                    self.mParentEventId = value as? Int64
                }else if(key == "groupId") {
                    self.mGroupId = value as? Int64
                }
            }
        }
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
        self.mEventAsyncHttpClient = EventAsyncHttpClient()
        self.mFetchHandler = FetchHandler(minGap: 0, maxGap: 5)
        self.mFetchHandler.fetch(0, visibleEndIndex: 5, fetchable: self)
        
        self.mAllEvents = Array<BaseEvent>()
        if (self.mGroupId != nil) {
            if (self.mParentEventId != nil) {
                self.mBaseEvent = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId!)!.getEventContainer().getBaseEvent(self.mParentEventId!)
                
                // hide propsed button based on eventmask
                if(!self.mBaseEvent!.getEventAttributeMask().isEventAttributeEditable(eventAttribute: BaseEvent.EventAttribute.ALLOW_EVENT_PROPOSAL)) {
                    self.mProposeEventButton.isEnabled = false
                }
                
                self.mChweetContainer = self.mBaseEvent!.getChweetContainer()
                self.createAllEventList()
            }else {
                showAlertMsg("event id is nil")
            }
        }else {
            showAlertMsg("group id is nil")
        }
        // tableView cell highlight
        self.mEventTimelineTableView.allowsSelection = false
        
        // tableView seperator line
        self.mEventTimelineTableView.separatorStyle = .none
        
        // tell tableView to use current class for datasource and delegate
        self.mEventTimelineTableView.delegate = self
        self.mEventTimelineTableView.dataSource = self
       
        // tell collectionView to use current class for datasource and delegate
        self.mChweetCollectionView.delegate = self
        self.mChweetCollectionView.dataSource = self

        // make chweet button round
        //self.mSendChweetButton.layer.cornerRadius = self.mSendChweetButton.frame.width / 2
        self.mChweetCollectionView.layer.borderWidth = 1
        self.mChweetCollectionView.layer.borderColor = UIColor(hex: Colors.md_gray_200).cgColor
        
    }
    
    @IBAction func onProposeEventButtonClicked(_ sender: UIBarButtonItem) {
        
        if (self.mBaseEvent!.getEventAttributeMask().isEventAttributeEditable(eventAttribute: BaseEvent.EventAttribute.ALLOW_EDITABLE_DIFFERENT_EVENT_TYPES)) {
            let selectNewEventViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "SelectNewEventViewController") as! SelectNewEventViewController
            selectNewEventViewCtr .mGroupId = self.mGroupId!
            selectNewEventViewCtr.mParentEventId = self.mBaseEvent!.getParentEventId()
            selectNewEventViewCtr.mParentEventType = self.mBaseEvent!.getParentEventTypeStr()
            self.present(selectNewEventViewCtr, animated: true, completion: nil)
            
        } else {
            let newBaseEventViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "NewBaseEventViewController") as! NewBaseEventViewController
            newBaseEventViewCtr .mGroupId = self.mGroupId!
            newBaseEventViewCtr.mParentEventId = self.mBaseEvent!.getParentEventId()
            newBaseEventViewCtr.mParentEventType = self.mBaseEvent!.getParentEventTypeStr()
            self.present(newBaseEventViewCtr, animated: true, completion: nil)
        }
        
    }
    @IBAction func onEventImagesButtonClicked(_ sender: UIBarButtonItem) {
        // launch image view controller
        let imageViewerVct = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewerViewController") as! ImageViewerViewController
        imageViewerVct.mGroupId = self.mGroupId
        imageViewerVct.mParentEventId = self.mParentEventId
        self.present(imageViewerVct, animated: true, completion: nil)
        
    }
    func getBaseGroup() -> BaseGroup {
        return DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId!)!
    }
    
    func getGlobalEventContainer() -> EventContainer {
        return DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId!)!.getEventContainer()
    }
    @IBAction func onSendChweetClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Chweet", message: "Please enter chweet message:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Send", style: .default) { (_) in
            
            if(alertController.textFields![0].text! != "") {
                self.mEventAsyncHttpClient.submitChweet(self.mUserIdStr, groupIdStr: String(self.mGroupId!), parentEventIdStr: String(describing: self.mParentEventId!), chatMsg: alertController.textFields![0].text!, respHandler: {
                    (_ statusCode: Int?, resp: Result<Any>) in
                        // on fetch response
                        if let statusCode: Int = statusCode {
                            let json = JSON(resp.value!)
                            if(statusCode ==  200) {
                            
                                let chweetId: Int64 = json["result"]["chweetId"].int64Value
                                let c = Chweet()
                                c.setChweetId(chweetId)
                                c.setChweetText(alertController.textFields![0].text!);
                                c.setChweetUserName(DcidrApplication.getInstance().getUser().getUserName())
                                c.setChweetParentEventId(self.mParentEventId!)
                                c.setChweetTime(Utils.currentTimeMillis())
                                //c.setChweetParentEventTypeId(self.m)
                                self.mChweetContainer.addChweet(c)
                                self.mChweetContainer.refreshChweetList()
                                self.mChweetCollectionView.reloadData()
                                
                                // scroll to first chweet
                                let indexPath = IndexPath(row: 0, section: 0)
                                self.mChweetCollectionView.scrollToItem(at: indexPath,
                                                                        at: UICollectionViewScrollPosition.left,
                                                                        animated: true)
                                
                                
                            }else {
                                self.showAlertMsg(json["error"].string!)
                            }
                        }else {
                            self.showAlertMsg("error sending chweet")
                    }
                })
            }else{
                self.showAlertMsg("chweet can not be empty")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        
        }
        
        alertController.addTextField {
            (textField) in
            textField.borderStyle = .none
            textField.placeholder = "Chweet Msg"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    func createAllEventList(){
        self.mAllEvents.removeAll()
        // add parent and child events to one temp container
        self.mAllEvents.append(self.mBaseEvent!)
        
        // set event last modified time to 0 for expired events
        //            for (BaseEvent childEvent : mBaseEvent.getChildEventsContainer().getEventList(EventContainer.TypeOfResult.ALL)) {
        //                childEvent.getUserEventStatusContainer().getUserEventStatusArray().clear();
        //            }
        self.mBaseEvent?.getChildEventsContainer().refreshEventList(EventContainer.TypeOfResult.ALL)
        self.mAllEvents.append(contentsOf: self.mBaseEvent!.getChildEventsContainer().getEventList(EventContainer.TypeOfResult.ALL))
        // wont work since getting a status count is done as we scroll
        for baseEvent in self.mAllEvents {
            baseEvent.setEventSortKey(BaseEvent.EventSortKey.EVENT_ACCEPTED_COUNT);
        }
        self.mAllEvents.sort(by: >)
    }
    
    
    // didSelectRowAtIndex -> Custom method
    func didSelectRowAt(indexPath: IndexPath) {
        // launch event timeline view controller
        let selectedEventVct = self.storyboard?.instantiateViewController(withIdentifier: "SelectedEventViewController") as! SelectedEventViewController
        selectedEventVct.mGroupId = self.mGroupId
        selectedEventVct.mEventId = self.mAllEvents[indexPath.row].getEventId()
        selectedEventVct.mParentEventId = self.mParentEventId
        self.present(selectedEventVct, animated: true, completion: nil)
        
    }
    
    // onNoOfRows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.mAllEvents.count)
        return self.mAllEvents.count
        
    }
    
    // onView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTimelineTableViewCell", for: indexPath) as! EventTimelineTableViewCell
        
        cell.setCellData(self, arrayList: self.mAllEvents)

        return cell.getCellView(indexPath: indexPath)
    }
    
    // chweet -> onNoOfRows
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mChweetContainer.getChweetList().count
    }
    
    // chweet -> onView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChweetCollectionViewCell", for: indexPath) as! ChweetCollectionViewCell
        
        cell.setCellData(self, arrayList: self.mChweetContainer.getChweetList())
        
        
        return cell.getCellView(indexPath: indexPath)
    }
    

    // chweet fetch methods
    func onFetchStart() {
        // show avtivity indicator
        //self.showUIActivityIndicator()
    }
    
    func onFetchRequested(_ offset: Int, limit: Int) {
        // get chweet
        self.mEventAsyncHttpClient.getChweet(self.mUserIdStr, groupIdStr: String(describing: self.mGroupId!), parentEventIdStr: String(describing: self.mParentEventId!), offset: 0, limit: 5, respHandler: self.mFetchHandler.getHttpRespHandler())
    }
    
    func onFetchResponse(_ statusCode: Int?, resp: Result<Any>) {
        // on fetch response
        //self.stopUIActivityIndicator()
        if let statusCode: Int = statusCode {
            let json = JSON(resp.value!)
            if(statusCode ==  200) {
                self.mChweetContainer.populateMe(json["result"])
                self.mChweetCollectionView.reloadData()
            }else {
                self.showAlertMsg(json["error"].string!)
            }
        }else {
            self.showAlertMsg("error fetching chweets")
        }

    }
    
    func onFetchSetEndIndex() -> Int {
        // set end index of the group container
        return self.mChweetContainer.getChweetList().count
    }

    
    
}

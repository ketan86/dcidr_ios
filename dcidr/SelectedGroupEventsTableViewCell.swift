//
//  CustomSelectedGroupEventTableViewCell.swift
//  dcidr
//
//  Created by John Smith on 1/3/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class SelectedGroupEventsTableViewCell : UITableViewCell {
    
    fileprivate var mBaseViewController: BaseViewController!
    fileprivate var mArrayList: Array<BaseEvent>!
    fileprivate var mBaseEvent: BaseEvent!
    @IBOutlet weak var mEventHolderScrollView: UIScrollView!
    @IBOutlet weak var mEventHolderStackView: UIStackView!
    func setCellData(_ baseViewController: BaseViewController, arrayList: Array<BaseEvent>){
        self.mBaseViewController = baseViewController
        self.mArrayList = arrayList
    }
    
    func getCellView(indexPath: IndexPath) -> SelectedGroupEventsTableViewCell {

        self.mBaseEvent = self.mArrayList[indexPath.row]
        // set parentEventView frames, width is half of the screen size and hight is same as parentEventView height
        let parentEventView = SelectedGroupEventCustomView(frame: CGRect(x: 8, y: 0, width: UIScreen.main.bounds.width / 2 , height: 60))
        
        // tag the views
        parentEventView.eventName.tag = 1
        parentEventView.eventTime.tag = 2
        parentEventView.eventLeaderColorStripe.tag = 3
        
        parentEventView.eventName.text = self.mBaseEvent.getEventName()
        parentEventView.eventTime.text = Utils.epochToDate(epoch: self.mBaseEvent.getStartTime())
        parentEventView.eventCreatedBy.text = self.mBaseEvent.getCreatedByName()!

        // register a tap gesture to parentEventView
        parentEventView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectedGroupEventsTableViewCell.onViewClicked)))
        
        self.mEventHolderScrollView.addSubview(parentEventView)

        // keep childXCord to half of the screen size
        var childXCord = UIScreen.main.bounds.width / 2 + 20
        
        // add all child views
        for childEvent in

            self.mBaseEvent.getChildEventsContainer().getEventList(EventContainer.TypeOfResult.ALL){
            // add a child view
            // set childEventView frame such as they are 10 points apart. width of the child event is 1/3 of the screen's width
            let childEventView = SelectedGroupEventCustomView(frame: CGRect(x: childXCord, y: 0, width: UIScreen.main.bounds.width / 3 , height: 60))
            
            childEventView.eventName.text = childEvent.getEventName()
            childEventView.eventTime.text = String(childEvent.getStartTime())
            childEventView.eventCreatedBy.text = childEvent.getCreatedByName()!
            // register a tap gesture to childEventView
            childEventView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectedGroupEventsTableViewCell.onViewClicked)))
            self.mEventHolderScrollView.addSubview(childEventView)
            
            // update childXCord
            childXCord += UIScreen.main.bounds.width / 3 + 10
            
            // update scrollView content size to allow scrolling
            self.mEventHolderScrollView.contentSize = CGSize(width: childXCord + 5, height: childEventView.frame.height)
        }

        // get userEventStatus data
        if(self.mBaseEvent.getUserEventStatusContainer().getUserEventStatusArray().count == 0) {
            self.fetchUserEventStatusData(self.mBaseEvent, doneCb: {
                self.highlightLeaderEvent()
            })
        }else {
            // already fetched
            self.highlightLeaderEvent()
        }
    
        return self
    }
    
    func highlightLeaderEvent() {
        // find out the leader and highlight it using color stripe
        let leaderEvent = self.mBaseEvent.getLeader()
        
        for view in self.mEventHolderScrollView.subviews {
            if let tempEventTypeColorStripe: UIView = view.viewWithTag(3) {
                if let tempEventName: UILabel = view.viewWithTag(1) as? UILabel {
                    if let tempEventTime: UILabel = view.viewWithTag(2) as? UILabel {
                        
                        if ((tempEventName.text! == leaderEvent.getEventName()) && (tempEventTime.text! == String(leaderEvent.getStartTime()))) {
                            //print("event" + tempEventName.text!)
                            //print("leader" + leaderEvent.getEventName())
                            tempEventTypeColorStripe.isHidden = false
                            tempEventTypeColorStripe.backgroundColor = UIColor(hex: Colors.yellowLightGreenColor)
                        }
                    }
                }
                
            }
        }

    }
    
    func fetchUserEventStatusData(_ baseEvent: BaseEvent, doneCb: @escaping ()->()) {
        let eventAsyncHttpClient = EventAsyncHttpClient()
        eventAsyncHttpClient.getUserEventStatus(String(DcidrApplication.getInstance().getUser().userId), groupIdStr: String(baseEvent.getGroupId()), eventIdStr: String(baseEvent.getEventId()), eventTypeStr: baseEvent.getEventTypeStr(), respHandler: {
            (statusCode, resp) in
            if let statusCode = statusCode {
                if(statusCode == 200){
                    if let respValue = resp.value {
                        let json = JSON(respValue)
                        baseEvent.getUserEventStatusContainer().setGroupId(baseEvent.getGroupId())
                        baseEvent.getUserEventStatusContainer().populateMe(json["result"]["userEventStatusData"])
                        for childEvent in baseEvent.getChildEventsContainer().getEventList(EventContainer.TypeOfResult.ALL) {
                            childEvent.getUserEventStatusContainer().setGroupId(childEvent.getGroupId())
                            childEvent.getUserEventStatusContainer().populateMe(json["result"]["childUserEventStatusData"][childEvent.getEventIdStr()])
                        }
                        doneCb()
                    }else {
                        self.mBaseViewController.showAlertMsg("error getting data from server")
                    }
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

        
    }
    
    func onViewClicked(sender: UIGestureRecognizer) {
        
        let selectedGroupEventsViewController = self.mBaseViewController as! SelectedGroupEventsViewController
        
        //using sender, we can get the point in respect to the table view
        let tapLocation = sender.location(in: selectedGroupEventsViewController.mSelectedGroupEventTableView)
        
        //using the tapLocation, we retrieve the corresponding indexPath
        let indexPath = selectedGroupEventsViewController.mSelectedGroupEventTableView.indexPathForRow(at: tapLocation)!
        
        selectedGroupEventsViewController.didSelectRowAt(indexPath: indexPath)
        
    }
}

//
//  SelectedGroupEventViewController.swift
//  dcidr
//
//  Created by John Smith on 12/30/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
class SelectedGroupEventsViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var mGroupId: Int64!
    fileprivate var mBaseGroup: BaseGroup? = nil
    @IBOutlet weak var mSelectedGroupEventTableView: UITableView!
    fileprivate var mTempEventContainer: EventContainer!
    fileprivate var mSelectedGroupEventsViewControllerHelper : SelectedGroupEventsViewControllerHelper!
    fileprivate var mEventContainer : EventContainer!
    fileprivate var mSearchString: String? = nil
    @IBOutlet weak var mSearchBar: UISearchBar!
    @IBOutlet weak var mEventTitleName: UINavigationItem!
    
    override func handleInputDataDict(data: [String: Any]?) {
        if let dict = data {
            for (key,value) in dict {
                if(key == "groupId") {
                    self.mGroupId = Int64(value as! String)
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
    
    
    @IBAction func onCreateEventButtonClicked(_ sender: UIBarButtonItem) {
        let selectNewEventViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "SelectNewEventViewController") as! SelectNewEventViewController
        selectNewEventViewCtr.mGroupId = self.mGroupId!
        selectNewEventViewCtr.mParentEventId = -1
        selectNewEventViewCtr.mParentEventType = String(describing: BaseEvent.EventType.UNKNOWN)
        self.present(selectNewEventViewCtr, animated: true, completion: nil)
    }
    @IBAction func mGroupInfoButtonClicked(_ sender: UIBarButtonItem) {
        // launch group detail view controller
        let groupDetailVct = self.storyboard?.instantiateViewController(withIdentifier: "GroupDetailViewController") as! GroupDetailViewController
        groupDetailVct.mGroupId = self.mGroupId
        self.present(groupDetailVct, animated: true, completion: nil)
    }
    
    override func initViewController(){
        
        self.mSelectedGroupEventsViewControllerHelper = SelectedGroupEventsViewControllerHelper(self)
        self.mTempEventContainer = EventContainer()
        
        if(self.mGroupId != nil){
            self.mBaseGroup = self.getBaseGroup()
            if(self.mBaseGroup != nil){
                self.initBaseGroup()
            }
        }else{
            print("group id is empty")
        }

        // tableView cell highlight
        self.mSelectedGroupEventTableView.allowsSelection = false
        
        // tableView seperator line 
        self.mSelectedGroupEventTableView.separatorStyle = .none
        
        // tell tableView to use current class for datasource and delegate
        self.mSelectedGroupEventTableView.delegate = self
        self.mSelectedGroupEventTableView.dataSource = self
        // tell searchBar to use current class for delegate
        self.mSearchBar.delegate = self
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.getTempEventContainer().clear()
        // clear all the searched results from the eventGroupContainer
        self.getGlobalEventContainer().deleteEvents(EventContainer.TypeOfResult.SEARCHED)
        // set end index to the size of the fetched group
        self.mSelectedGroupEventsViewControllerHelper.getFetchHandler().getFetchManager().setEndIndex(self.getGlobalEventContainer().getEventList(EventContainer.TypeOfResult.SCROLLED).count)
        
        // set searchString to nil and then reload the data
        self.mSearchString = nil
        self.mSelectedGroupEventTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // implement search logic here
        self.mSearchString = searchText.lowercased()
        if(self.mSearchString != "") {
            
            // clear mTempEventContainer groupList
            self.mTempEventContainer.clear()
            
            //clear fetchManager start and end index since each search will want a new initialization
            self.mSelectedGroupEventsViewControllerHelper.getFetchHandler().getFetchManager().reset()
            // fetch groups for 0 with the search string
            self.mSelectedGroupEventsViewControllerHelper.fetchEvents(0, visibleEndIndex: 5, searchString: self.mSearchString!)
            
            self.mSelectedGroupEventTableView.reloadData()
            
        }else {
            self.searchBarCancelButtonClicked(self.mSearchBar)
        }
        
    }
    
    
    
    func getBaseGroup() -> BaseGroup {
        return DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId!)!
    }
    
    func getGlobalEventContainer() -> EventContainer {
        return DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId!)!.getEventContainer()
    }
    
    func getTempEventContainer() -> EventContainer {
        return mTempEventContainer;
    }


    
    func initBaseGroup(){
        self.mBaseGroup?.unreadEventCount = 0
        // set title to specific group name
        self.mEventTitleName.title = self.mBaseGroup!.groupName
    }
    
    @IBAction func onCancelButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // no-op instead using
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
        // launch event timeline view controller
        let eventTimelineVct = self.storyboard?.instantiateViewController(withIdentifier: "EventTimelineViewController") as! EventTimelineViewControlller
        eventTimelineVct.mGroupId = self.mGroupId
        eventTimelineVct.mParentEventId = self.getGlobalEventContainer().getEventList(EventContainer.TypeOfResult.ALL)[indexPath.row].getEventId()
        self.present(eventTimelineVct, animated: true, completion: nil)

    }
    
    // onNoOfRows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.mSearchString == nil) {
            print(self.getGlobalEventContainer().getEventList(EventContainer.TypeOfResult.SCROLLED).count)
            return self.getGlobalEventContainer().getEventList(EventContainer.TypeOfResult.SCROLLED).count
        }else {
            return self.getTempEventContainer().getEventList(EventContainer.TypeOfResult.ALL).count
        }
    }
    
    // onView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedGroupEventsTableViewCell", for: indexPath) as! SelectedGroupEventsTableViewCell
                
        if(self.mSearchString == nil) {
            cell.setCellData(self, arrayList: self.getGlobalEventContainer().getEventList(EventContainer.TypeOfResult.SCROLLED))
        }else {
            cell.setCellData(self, arrayList: self.getTempEventContainer().getEventList(EventContainer.TypeOfResult.ALL))
        }
        return cell.getCellView(indexPath: indexPath)
    }
    
    // onScroll
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.mSelectedGroupEventsViewControllerHelper.fetchEvents(indexPath.row - self.mSelectedGroupEventTableView.visibleCells.count, visibleEndIndex: indexPath.row - 1, searchString: self.mSearchString)
    }
    
    func onFetchResponse(_ statusCode: Int?, resp: Result<Any>){
        if let statusCode: Int = statusCode {
            let json = JSON(resp.value!)
            if(statusCode ==  200) {
                if(self.mSearchString == nil) {
                    self.getGlobalEventContainer().setBaseGroup(self.getBaseGroup())
                    self.getGlobalEventContainer().populateEvents(json["result"])
                    self.getGlobalEventContainer().refreshEventList(EventContainer.TypeOfResult.SCROLLED)
                }else {
                    self.getTempEventContainer().setBaseGroup(self.getBaseGroup())
                    self.getTempEventContainer().populateEvents(json["result"])
                    self.getGlobalEventContainer().populateEvents(self.getTempEventContainer().getEventList(EventContainer.TypeOfResult.ALL), isSearchedResult: true)
                    self.getTempEventContainer().refreshEventList(EventContainer.TypeOfResult.ALL)
                }
                self.mSelectedGroupEventTableView.reloadData()
            }else {
                self.showAlertMsg(json["error"].string!)
            }
        }else {
            self.showAlertMsg("error fetching groups")
        }
    }

    
}

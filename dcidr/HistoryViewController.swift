//
//  HistoryViewController.swift
//  dcidr
//
//  Created by John Smith on 1/28/17.
//  Copyright © 2017 dcidr. All rights reserved.
//
import Foundation
import UIKit
import Alamofire
import SwiftyJSON
class HistoryViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    fileprivate var mGlobalHistoryContainer = DcidrApplication.getInstance().getGlobalHistoryContainer()
    fileprivate var mHistoryViewControllerHelper : HistoryViewControllerHelper!
    fileprivate var mTempHistoryContainer: HistoryContainer!
    fileprivate var mSearchString: String? = nil
    @IBOutlet weak var mSearchBar: UISearchBar!
    
    @IBOutlet weak var mHistoryTableView: UITableView!
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
        self.mHistoryViewControllerHelper = HistoryViewControllerHelper(self)
        self.mTempHistoryContainer = HistoryContainer()
        // tell tableView to use current class for datasource and delegate
        self.mHistoryTableView.delegate = self
        self.mHistoryTableView.dataSource = self
        // tell searchBar to use current class for delegate
        self.mSearchBar.delegate = self
        
    }
    
    @IBAction func logoutButtonClicked(_ sender: UIBarButtonItem) {
        // launch main controller
        let loginViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(loginViewCtr, animated: true, completion: nil)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.mTempHistoryContainer.clear()
        // clear all the searched results from the globalHistoryContainer
        self.mGlobalHistoryContainer.deleteGroups(HistoryContainer.TypeOfResult.SEARCHED)
        // set end index to the size of the fetched History
        self.mHistoryViewControllerHelper.getFetchHandler().getFetchManager().setEndIndex(self.mGlobalHistoryContainer.getGroupContainerEventList(EventContainer.TypeOfResult.SCROLLED).count)
        
        // set searchString to nil and then reload the data
        self.mSearchString = nil
        self.mHistoryTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // implement search logic here
        self.mSearchString = searchText.lowercased()
        if(self.mSearchString != "") {
            
            // clear mTempHistoryContainer HistoryList
            self.mTempHistoryContainer.clear()
            
            //clear fetchManager start and end index since each search will want a new initialization
            self.mHistoryViewControllerHelper.getFetchHandler().getFetchManager().reset()
            // fetch Historys for 0 with the search string
            self.mHistoryViewControllerHelper.fetchHistory(0, visibleEndIndex: 5, searchString: self.mSearchString!)
            
            self.mHistoryTableView.reloadData()
            
        }else {
            self.searchBarCancelButtonClicked(self.mSearchBar)
        }
        
    }
    
    
    
    func getGlobalHistoryContainer() -> HistoryContainer {
        return self.mGlobalHistoryContainer
    }
    
    func getTempHistoryContainer() -> HistoryContainer {
        return self.mTempHistoryContainer
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // launch event details view controller
        let eventDetailViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        eventDetailViewCtr.mGroupId = self.mGlobalHistoryContainer.getGroupContainerEventList(EventContainer.TypeOfResult.SCROLLED)[indexPath.row].getBaseGroup()!.groupId
        eventDetailViewCtr.mParentEventId = self.mGlobalHistoryContainer.getGroupContainerEventList(EventContainer.TypeOfResult.SCROLLED)[indexPath.row].getParentEventId()
        eventDetailViewCtr.mEventId = self.mGlobalHistoryContainer.getGroupContainerEventList(EventContainer.TypeOfResult.SCROLLED)[indexPath.row].getEventId()
        self.present(eventDetailViewCtr, animated: true, completion: nil)
    }
    
    // onNoOfRows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.mSearchString == nil) {
            //print("global: " + String(self.mGlobalHistoryContainer.getHistoryList(HistoryContainer.TypeOfResult.SCROLLED).count))
            return self.mGlobalHistoryContainer.getGroupContainerEventList(EventContainer.TypeOfResult.SCROLLED).count
        }else {
            //print("searched: " + String(self.mTempHistoryContainer.getHistoryList(HistoryContainer.TypeOfResult.ALL).count))
            return self.mTempHistoryContainer.getGroupContainerEventList(EventContainer.TypeOfResult.ALL).count
        }
    }
    
    // onView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        if(self.mSearchString == nil) {
            cell.setCellData(self, arrayList: self.mGlobalHistoryContainer.getGroupContainerEventList(EventContainer.TypeOfResult.SCROLLED))
        }else {
            cell.setCellData(self, arrayList: self.mTempHistoryContainer.getGroupContainerEventList(EventContainer.TypeOfResult.ALL))
        }
        return cell.getCellView(indexPath: indexPath)
    }
    
    // onScroll
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.mHistoryViewControllerHelper.fetchHistory(indexPath.row - self.mHistoryTableView.visibleCells.count, visibleEndIndex: indexPath.row - 1, searchString: self.mSearchString)
    }
    
    
    func onFetchResponse(_ statusCode: Int?, resp: Result<Any>){
        if let statusCode: Int = statusCode {
            let json = JSON(resp.value!)
            if(statusCode ==  200) {
                if(self.mSearchString == nil) {
                    self.mGlobalHistoryContainer.populateGroup(json["result"])
                    for i in json["result"].array! {
                        let groupId = i["groupId"].int64Value
                        let baseGroup = self.mGlobalHistoryContainer.getBaseGroup(groupId)!
                        baseGroup.getEventContainer().setBaseGroup(baseGroup)
                        baseGroup.getEventContainer().populateEvent(i)
                    }
                    self.mGlobalHistoryContainer.refreshGroupContainerEventList(EventContainer.TypeOfResult.SCROLLED)
                }else {
                    self.mTempHistoryContainer.populateGroup(json["result"])
                    for i in json["result"].array! {
                        let groupId = i["groupId"].int64Value
                        let baseGroup = self.mTempHistoryContainer.getBaseGroup(groupId)!
                        baseGroup.getEventContainer().setBaseGroup(baseGroup)
                        baseGroup.getEventContainer().populateEvent(i)
                    }
                    self.mGlobalHistoryContainer.populateGroups(self.mTempHistoryContainer.getGroupList(GroupContainer.TypeOfResult.ALL), isSearchedResult: true)
                    self.mTempHistoryContainer.refreshGroupContainerEventList(EventContainer.TypeOfResult.ALL)
                }
                self.mHistoryTableView.reloadData()
            }else {
                self.showAlertMsg(json["error"].string!)
            }
        }else {
            self.showAlertMsg("error fetching groups")
        }
    }
    
    
    
}

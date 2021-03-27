//
//  GroupViewController.swift
//  dcidr
//
//  Created by John Smith on 12/28/16.
//  Copyright © 2016 dcidr. All rights reserved.
//
import Foundation
import UIKit
import Alamofire
import SwiftyJSON
class GroupViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var mGroupTableView: UITableView!
    fileprivate var mGlobalGroupContainer = DcidrApplication.getInstance().getGlobalGroupContainer()
    fileprivate var mGroupViewControllerHelper : GroupViewControllerHelper!
    fileprivate var mTempGroupContainer: GroupContainer!
    fileprivate var mSearchString: String? = nil
    @IBOutlet weak var mSearchBar: UISearchBar!
    
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
        self.mGroupViewControllerHelper = GroupViewControllerHelper(self)
        self.mTempGroupContainer = GroupContainer()
        // tell tableView to use current class for datasource and delegate
        self.mGroupTableView.delegate = self
        self.mGroupTableView.dataSource = self
        // tell searchBar to use current class for delegate
        self.mSearchBar.delegate = self
        
    }
    
    @IBAction func logoutButtonClicked(_ sender: UIBarButtonItem) {
        //let mvc = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
//        let bnh = BaseFcmNtfHandler()
//        let dict = [
//            "viewController" : "MapViewController",
//            "data" : [
//                "mLatitude" : 0.2,
//                "mLongitude" : 1.2,
//                "mMarkerTitle" : "hello",
//                "mMarkerSnippet" : "John"
//                ]
//        ] as [String : Any]
//        bnh.sendNotification(userIdStr: "123", title: "hi", body: "First notification", keyValue: dict)
        let userViewCtrHelper = UserViewControllerHelper(baseViewController: self)
        userViewCtrHelper.logoutUser()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.mTempGroupContainer.clear()
        // clear all the searched results from the globalGroupContainer
        self.mGlobalGroupContainer.deleteGroups(GroupContainer.TypeOfResult.SEARCHED)
        // set end index to the size of the fetched group
        self.mGroupViewControllerHelper.getFetchHandler().getFetchManager().setEndIndex(self.mGlobalGroupContainer.getGroupList(GroupContainer.TypeOfResult.SCROLLED).count)
        
        // set searchString to nil and then reload the data
        self.mSearchString = nil
        self.mGroupTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // implement search logic here
        self.mSearchString = searchText.lowercased()
        if(self.mSearchString != "") {
            
            // clear mTempGroupContainer groupList
            self.mTempGroupContainer.clear()
            
            //clear fetchManager start and end index since each search will want a new initialization
            self.mGroupViewControllerHelper.getFetchHandler().getFetchManager().reset()
            // fetch groups for 0 with the search string
            self.mGroupViewControllerHelper.fetchGroups(0, visibleEndIndex: 5, searchString: self.mSearchString!)
            
            self.mGroupTableView.reloadData()

        }else {
            self.searchBarCancelButtonClicked(self.mSearchBar)
        }
        
    }
    
   
    
    func getGlobalGroupContainer() -> GroupContainer {
        return self.mGlobalGroupContainer
    }
    
    func getTempGroupContainer() -> GroupContainer {
        return self.mTempGroupContainer
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // launch selected group event view controller
        let selectedGroupEventViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "SelectedGroupEventsViewController") as! SelectedGroupEventsViewController
        selectedGroupEventViewCtr.mGroupId = self.mGlobalGroupContainer.getGroupList(GroupContainer.TypeOfResult.ALL)[indexPath.row].groupId
        self.present(selectedGroupEventViewCtr, animated: true, completion: nil)
    }
    
    // onNoOfRows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.mSearchString == nil) {
            //print("global: " + String(self.mGlobalGroupContainer.getGroupList(GroupContainer.TypeOfResult.SCROLLED).count))
            return self.mGlobalGroupContainer.getGroupList(GroupContainer.TypeOfResult.SCROLLED).count
        }else {
            //print("searched: " + String(self.mTempGroupContainer.getGroupList(GroupContainer.TypeOfResult.ALL).count))
            return self.mTempGroupContainer.getGroupList(GroupContainer.TypeOfResult.ALL).count
        }
    }
    
    // onView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell", for: indexPath) as! GroupTableViewCell
        if(self.mSearchString == nil) {
            cell.setCellData(self, arrayList: self.mGlobalGroupContainer.getGroupList(GroupContainer.TypeOfResult.SCROLLED))
        }else {
            cell.setCellData(self, arrayList: self.mTempGroupContainer.getGroupList(GroupContainer.TypeOfResult.ALL))
        }
        return cell.getCellView(indexPath: indexPath)
    }
    
    // onScroll
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.mGroupViewControllerHelper.fetchGroups(indexPath.row - self.mGroupTableView.visibleCells.count, visibleEndIndex: indexPath.row - 1, searchString: self.mSearchString)
    }
    
    func onFetchResponse(_ statusCode: Int?, resp: Result<Any>){
        if let statusCode: Int = statusCode {
            let json = JSON(resp.value!)
            if(statusCode ==  200) {
                if(self.mSearchString == nil) {
                    self.mGlobalGroupContainer.populateGroup(json["result"])
                    self.mGlobalGroupContainer.refreshGroupList(GroupContainer.TypeOfResult.SCROLLED)
                }else {
                    self.mTempGroupContainer.populateGroup(json["result"])
                    self.mGlobalGroupContainer.populateGroups(self.mTempGroupContainer.getGroupList(GroupContainer.TypeOfResult.ALL), isSearchedResult: true)
                    self.mTempGroupContainer.refreshGroupList(GroupContainer.TypeOfResult.ALL)
                }
                self.mGroupTableView.reloadData()
            }else {
                self.showAlertMsg(json["error"].string!)
            }
        }else {
            self.showAlertMsg("error fetching groups")
        }
    }
    
        
}

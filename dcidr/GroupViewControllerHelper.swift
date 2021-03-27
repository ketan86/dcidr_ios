//
//  GroupViewControllerHelper.swift
//  dcidr
//
//  Created by John Smith on 1/13/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
class GroupViewControllerHelper: Fetchable {
    fileprivate let mGroupViewController : GroupViewController!
    fileprivate let mFetchHandler: FetchHandler!
    fileprivate let mGroupAsyncHttpClient: GroupAsyncHttpClient!
    fileprivate let mUserId: String = DcidrApplication.getInstance().getUser().userId
    fileprivate var mSearchString: String? = nil
    
    init(_ groupViewController: GroupViewController) {
        self.mGroupViewController = groupViewController
        self.mGroupAsyncHttpClient = GroupAsyncHttpClient()
        self.mFetchHandler = FetchHandler(minGap: 5, maxGap: 5)
        self.mFetchHandler.fetch(0, visibleEndIndex: 5, fetchable: self)
    }
    
    func fetchGroups(_ visibleStartIndex: Int, visibleEndIndex: Int, searchString: String?){
        self.mSearchString = searchString
        self.mFetchHandler.fetch(visibleStartIndex, visibleEndIndex: visibleEndIndex, fetchable: self)
    }
    
    
    func getFetchHandler() -> FetchHandler {
        return self.mFetchHandler
    }
    func onFetchStart() {
        // show avtivity indicator
        self.mGroupViewController.showUIActivityIndicator()
    }
    
    func onFetchRequested(_ offset: Int, limit: Int) {
        // get groups
        if(self.mSearchString == nil) {
            self.mGroupAsyncHttpClient.getGroups(self.mUserId, offset: offset, limit: limit, respHandler: self.mFetchHandler.getHttpRespHandler())
        }else {
            self.mGroupAsyncHttpClient.getGroupsByQueryText(self.mUserId, queryText: self.mSearchString!, offset: offset, limit: limit, respHandler: self.mFetchHandler.getHttpRespHandler())
        }
        
    }
    
    func onFetchResponse(_ statusCode: Int?, resp: Result<Any>) {
        // on fetch response
        self.mGroupViewController.stopUIActivityIndicator()
        self.mGroupViewController.onFetchResponse(statusCode, resp:resp)
    }
    
    func onFetchSetEndIndex() -> Int {
        // set end index of the group container
        if(self.mSearchString == nil) {
            return self.mGroupViewController.getGlobalGroupContainer().getGroupList(GroupContainer.TypeOfResult.SCROLLED).count
        }else {
            return self.mGroupViewController.getTempGroupContainer().getGroupList(GroupContainer.TypeOfResult.ALL).count
        }
        
    }

    
}

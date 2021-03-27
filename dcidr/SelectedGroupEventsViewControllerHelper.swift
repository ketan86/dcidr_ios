//
//  SelectedGroupEventsViewControllerHelper.swift
//  dcidr
//
//  Created by John Smith on 1/14/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import Alamofire
class SelectedGroupEventsViewControllerHelper: Fetchable {
    fileprivate let mSelectedGroupEventsViewController: SelectedGroupEventsViewController!
    fileprivate let mFetchHandler: FetchHandler!
    fileprivate let mEventAsyncHttpClient: EventAsyncHttpClient!
    fileprivate let mUserId: String = DcidrApplication.getInstance().getUser().userId
    fileprivate var mSearchString: String? = nil
    
    init(_ selectedGroupEventsViewController: SelectedGroupEventsViewController) {
        self.mSelectedGroupEventsViewController = selectedGroupEventsViewController
        self.mEventAsyncHttpClient = EventAsyncHttpClient()
        self.mFetchHandler = FetchHandler(minGap: 5, maxGap: 5)
        self.mFetchHandler.fetch(0, visibleEndIndex: 5, fetchable: self)
    }
    
    func fetchEvents(_ visibleStartIndex: Int, visibleEndIndex: Int, searchString: String?){
        self.mSearchString = searchString
        self.mFetchHandler.fetch(visibleStartIndex, visibleEndIndex: visibleEndIndex, fetchable: self)
    }
    
    
    func getFetchHandler() -> FetchHandler {
        return self.mFetchHandler
    }
    func onFetchStart() {
        // show avtivity indicator
        self.mSelectedGroupEventsViewController.showUIActivityIndicator()
    }
    
    func onFetchRequested(_ offset: Int, limit: Int) {
        // get events
        if(self.mSearchString == nil) {
            self.mEventAsyncHttpClient.getEvents(self.mUserId, groupIdStr: String(self.mSelectedGroupEventsViewController.getBaseGroup().groupId) ,offset: offset, limit: limit, respHandler: self.mFetchHandler.getHttpRespHandler())
        }else {
            self.mEventAsyncHttpClient.getEventsByQueryText(self.mUserId, groupIdStr: String(self.mSelectedGroupEventsViewController.getBaseGroup().groupId) , queryText: self.mSearchString!, offset: offset, limit: limit, respHandler: self.mFetchHandler.getHttpRespHandler())
        }
        
    }
    
    func onFetchResponse(_ statusCode: Int?, resp: Result<Any>) {
        // on fetch response
        self.mSelectedGroupEventsViewController.stopUIActivityIndicator()
        self.mSelectedGroupEventsViewController.onFetchResponse(statusCode, resp:resp)
    }
    
    func onFetchSetEndIndex() -> Int {
        // set end index of the event container
        if(self.mSearchString == nil) {
            return self.mSelectedGroupEventsViewController.getGlobalEventContainer().getEventList(EventContainer.TypeOfResult.SCROLLED).count
        }else {
            return self.mSelectedGroupEventsViewController.getTempEventContainer().getEventList(EventContainer.TypeOfResult.ALL).count
        }
        
    }
    
    
}

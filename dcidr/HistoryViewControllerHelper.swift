//
//  HistoryViewControllerHelper.swift
//  dcidr
//
//  Created by John Smith on 1/28/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
class HistoryViewControllerHelper: Fetchable {
    fileprivate let mHistoryViewController : HistoryViewController!
    fileprivate let mFetchHandler: FetchHandler!
    fileprivate let mHistoryAsyncHttpClient: HistoryAsyncHttpClient!
    fileprivate let mUserId: String = DcidrApplication.getInstance().getUser().userId
    fileprivate var mSearchString: String? = nil
    
    init(_ historyViewController: HistoryViewController) {
        self.mHistoryViewController = historyViewController
        self.mHistoryAsyncHttpClient = HistoryAsyncHttpClient()
        self.mFetchHandler = FetchHandler(minGap: 5, maxGap: 5)
        self.mFetchHandler.fetch(0, visibleEndIndex: 5, fetchable: self)
    }
    
    func fetchHistory(_ visibleStartIndex: Int, visibleEndIndex: Int, searchString: String?){
        self.mSearchString = searchString
        self.mFetchHandler.fetch(visibleStartIndex, visibleEndIndex: visibleEndIndex, fetchable: self)
    }
    
    
    func getFetchHandler() -> FetchHandler {
        return self.mFetchHandler
    }
    func onFetchStart() {
        // show avtivity indicator
        self.mHistoryViewController.showUIActivityIndicator()
    }
    
    func onFetchRequested(_ offset: Int, limit: Int) {
        // get History
        if(self.mSearchString == nil) {
            self.mHistoryAsyncHttpClient.getHistory(self.mUserId, offset: offset, limit: limit, respHandler: self.mFetchHandler.getHttpRespHandler())
        }else {
            self.mHistoryAsyncHttpClient.getHistoryByQueryText(self.mUserId, queryText: self.mSearchString!, offset: offset, limit: limit, respHandler: self.mFetchHandler.getHttpRespHandler())
        }
        
    }
    
    func onFetchResponse(_ statusCode: Int?, resp: Result<Any>) {
        // on fetch response
        self.mHistoryViewController.stopUIActivityIndicator()
        self.mHistoryViewController.onFetchResponse(statusCode, resp:resp)
    }
    
    func onFetchSetEndIndex() -> Int {
        // set end index of the History container
        if(self.mSearchString == nil) {
            return self.mHistoryViewController.getGlobalHistoryContainer().getGroupContainerEventList(EventContainer.TypeOfResult.SCROLLED).count
        }else {
            return self.mHistoryViewController.getTempHistoryContainer().getGroupContainerEventList(EventContainer.TypeOfResult.ALL).count
        }
        
    }
    
    
}

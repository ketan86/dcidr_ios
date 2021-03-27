//
//  DcidrContactViewControllerHelper.swift
//  dcidr
//
//  Created by John Smith on 1/29/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import Alamofire
class DcidrContactsViewControllerHelper : BaseContactsViewControllerHelper, Fetchable {
    
    fileprivate var mFetchHandler: FetchHandler!
    fileprivate var mUserAsyncHttpClient: UserAsyncHttpClient!
    fileprivate var mSearchString: String? = nil
    
    override init(_ contactsViewController: ContactsViewController) {
        super.init(contactsViewController)
        self.mUserAsyncHttpClient = UserAsyncHttpClient()
        self.mFetchHandler = FetchHandler(minGap: 5, maxGap: 5)
        self.mFetchHandler.fetch(0, visibleEndIndex: 1000000, fetchable: self)

    }
    
    func fetchContats(_ visibleStartIndex: Int, visibleEndIndex: Int, searchString: String?){
        self.mSearchString = searchString
        self.mFetchHandler.fetch(visibleStartIndex, visibleEndIndex: visibleEndIndex, fetchable: self)
    }
    
    
    func getFetchHandler() -> FetchHandler {
        return self.mFetchHandler
    }
    func onFetchStart() {
        // show avtivity indicator
        self.mContatsViewController.showUIActivityIndicator()
    }
    
    func onFetchRequested(_ offset: Int, limit: Int) {
        // get contacts
        self.mUserAsyncHttpClient.getDirectAndIndirectContacts(self.mUserId, offset: offset, limit: limit, queryText: self.mSearchString, respHandler: self.mFetchHandler.getHttpRespHandler())
    }
    
    func onFetchResponse(_ statusCode: Int?, resp: Result<Any>) {
        // on fetch response
        self.mContatsViewController.stopUIActivityIndicator()
        self.mContatsViewController.onFetchResponse(statusCode, resp:resp)
    }
    
    func onFetchSetEndIndex() -> Int {
        // set end index of the Contact container
        if(self.mSearchString == nil) {
            return self.mContatsViewController.getGlobalContactContainer().getContactList(typeOfResult: ContactContainer.TypeOfResult.SCROLLED).count
        }else {
            return self.mContatsViewController.getTempContactContainer().getContactList(typeOfResult: ContactContainer.TypeOfResult.ALL).count
        }
        
    }
    

    
    
    
}

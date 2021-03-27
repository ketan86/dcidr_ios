//
//  ContactInvitationViewControllerHelper.swift
//  dcidr
//
//  Created by John Smith on 1/29/17.
//  Copyright © 2017 dcidr. All rights reserved.
//


import Foundation
import Alamofire
import SwiftyJSON
class ContactInvitationViewControllerHelper: Fetchable {
    enum InvitationType {
        case INCOMING, OUTGOING
    }
    
    fileprivate let mContactInvitationViewController : ContactInvitationViewController!
    fileprivate let mFetchHandler: FetchHandler!
    fileprivate let mUserAsyncHttpClient: UserAsyncHttpClient!
    fileprivate let mUserIdStr: String = DcidrApplication.getInstance().getUser().getUserIdStr()
    fileprivate var mInvitationType: InvitationType!
    init(_ contactInvitationViewController: ContactInvitationViewController) {
        self.mContactInvitationViewController = contactInvitationViewController
        self.mUserAsyncHttpClient = UserAsyncHttpClient()
        self.mFetchHandler = FetchHandler(minGap: 5, maxGap: 5)
    }
    
    func setInvitationType(type: InvitationType) {
        self.mInvitationType = type
    }
    
    func fetchContacts(_ visibleStartIndex: Int, visibleEndIndex: Int){
        self.mFetchHandler.fetch(visibleStartIndex, visibleEndIndex: visibleEndIndex, fetchable: self)
    }
    
    func getFetchHandler() -> FetchHandler {
        return self.mFetchHandler
    }
    func onFetchStart() {
        // show avtivity indicator
        self.mContactInvitationViewController.showUIActivityIndicator()
    }
    
    func onFetchRequested(_ offset: Int, limit: Int) {
        // get History
        var invitedBy: String? = nil
        if(self.mInvitationType == InvitationType.INCOMING) {
            invitedBy = "true"
        }else if (self.mInvitationType == InvitationType.OUTGOING) {
            invitedBy = "false"
        }
        self.mUserAsyncHttpClient.getFriends(self.mUserIdStr, status: String(describing: Contact.StatusType.INVITED), inviteBy: invitedBy!, offset: offset, limit: limit, respHandler: self.mFetchHandler.getHttpRespHandler())
    }
    
    func onFetchResponse(_ statusCode: Int?, resp: Result<Any>) {
        // on fetch response
        self.mContactInvitationViewController.stopUIActivityIndicator()
        self.mContactInvitationViewController.onFetchResponse(invitationType: self.mInvitationType, statusCode: statusCode, resp:resp)
    }
    
    func onFetchSetEndIndex() -> Int {
        // set end index of the History container
        if(self.mInvitationType == InvitationType.INCOMING) {
            return self.mContactInvitationViewController.getInInvitationContactContainer().getContactList(typeOfResult: ContactContainer.TypeOfResult.ALL).count
        }else if (self.mInvitationType == InvitationType.OUTGOING) {
            return self.mContactInvitationViewController.getOutInvitationContactContainer().getContactList(typeOfResult: ContactContainer.TypeOfResult.ALL).count
        }
        return 0
    }
    
    
}

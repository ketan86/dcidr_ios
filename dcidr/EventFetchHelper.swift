//
//  EventFetchHelper.swift
//  dcidr
//
//  Created by John Smith on 3/25/17.
//  Copyright © 2017 dcidr. All rights reserved.
//
import Foundation
import SwiftyJSON
class EventFetchHelper {
    fileprivate var mUserIdStr: String!
    init() {
        self.mUserIdStr = DcidrApplication.getInstance().getUserCache().getPref("userId")
    }
    func fetchEvent(groupIdStr: String, eventIdStr: String, fetchSuccessCb: @escaping () -> (), fetchFailureCb: @escaping () -> ()) {
        let eventAsyncHttpClient = EventAsyncHttpClient()
        eventAsyncHttpClient.getEvent(self.mUserIdStr, groupIdStr: groupIdStr, eventIdStr: eventIdStr) { (statusCode, resp) in
            if let statusCode: Int = statusCode {
                let json = JSON(resp.value!)
                if(statusCode ==  200) {
                    let baseGroup = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(Int64(groupIdStr)!)
                    baseGroup!.getEventContainer().populateEvent(json["result"])
                    fetchSuccessCb()
                }else {
                    fetchFailureCb()
                }
            }else {
                fetchFailureCb()
            }
        }
    }
}

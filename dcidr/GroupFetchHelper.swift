//
//  GroupFetchHelper.swift
//  dcidr
//
//  Created by John Smith on 3/25/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class GroupFetchHelper {
    fileprivate var mUserIdStr: String!
    init() {
        self.mUserIdStr = DcidrApplication.getInstance().getUserCache().getPref("userId")
    }
    func fetchGroup(groupIdStr: String, fetchSuccessCb: @escaping (JSON) -> (), fetchFailureCb: @escaping () -> ()) {
        let groupAsyncHttpClient = GroupAsyncHttpClient()
        groupAsyncHttpClient.getGroup(self.mUserIdStr, groupIdStr: groupIdStr) { (statusCode, resp) in
            if let statusCode: Int = statusCode {
                let json = JSON(resp.value!)
                if(statusCode ==  200) {
                    fetchSuccessCb(json["result"])
                }else {
                    fetchFailureCb()
                }
            }else {
                fetchFailureCb()
            }
        }
    }
}

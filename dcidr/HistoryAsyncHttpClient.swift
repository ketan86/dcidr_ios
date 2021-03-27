//
//  HistoryAsyncHttpClient.swift
//  dcidr
//
//  Created by John Smith on 1/28/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import Alamofire
class HistoryAsyncHttpClient: BaseAsyncHttpClient {
    override init(){
        super.init()
    }
    

    func getHistory(_ userIdStr: String, offset: Int, limit: Int, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_HISTORY_GET_URL = DcidrConstant.USER_HISTORY_GET_URL
        USER_HISTORY_GET_URL =  (USER_HISTORY_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_HISTORY_GET_URL = USER_HISTORY_GET_URL + "?offset=" + String(offset) + "&limit=" + String(limit)
        self.get(USER_HISTORY_GET_URL, respCb: respHandler)

    }
    
    func getHistoryByQueryText(_ userIdStr: String, queryText: String, offset: Int, limit: Int, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_HISTORY_GET_URL = DcidrConstant.USER_HISTORY_GET_URL
        USER_HISTORY_GET_URL =  (USER_HISTORY_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_HISTORY_GET_URL = USER_HISTORY_GET_URL + "?offset=" + String(offset) + "&limit=" + String(limit) + "&has=" + queryText
        self.get(USER_HISTORY_GET_URL, respCb: respHandler)
    }
}

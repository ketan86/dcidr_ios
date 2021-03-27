//
//  FetchManagerHandler.swift
//  dcidr
//
//  Created by John Smith on 12/29/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import Alamofire
protocol Fetchable {
    func onFetchRequested(_ offset:Int, limit:Int)
    func onFetchSetEndIndex() -> Int
    func onFetchStart()
    func onFetchResponse(_ statusCode:Int?, resp: Result<Any>)
}

class FetchHandler {
    fileprivate var mFetchManager: FetchManager
    fileprivate var mFetchable: Fetchable?
    fileprivate var mHttpRespHandler: (Int?, Result<Any>) -> () = {
        (statusCode, resp) -> () in
    }
    init(minGap:Int, maxGap:Int) {
        self.mFetchManager = FetchManager(minGap: minGap, maxGap: maxGap)
        self.mHttpRespHandler = {
            (statusCode, resp) -> () in
            if let unwrapped = statusCode {
                self.mFetchable!.onFetchResponse(unwrapped, resp: resp)
                self.mFetchManager.setEndIndex(self.mFetchable!.onFetchSetEndIndex())
            }else {
                self.mFetchable!.onFetchResponse(statusCode, resp: resp)            }
        }
    }
    
    func getFetchManager() -> FetchManager {
        return self.mFetchManager
    }
    
    func getHttpRespHandler() -> (_ statusCode: Int?, _ resp: Result<Any>)->() {
        return self.mHttpRespHandler
    }
    
    
    func fetch(_ visibleStartIndex: Int, visibleEndIndex: Int, fetchable: Fetchable) {
        self.mFetchable = fetchable
        self.mFetchManager.fetch(visibleStartIndex, visibleEndIndex: visibleEndIndex, fetchManagerCb: { (offset, limit) in
            self.mFetchable!.onFetchStart()
            self.mFetchable!.onFetchRequested(offset, limit: limit)
        })
    }
}

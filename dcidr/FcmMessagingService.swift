//
//  FcmMessagingService.swift
//  dcidr
//
//  Created by John Smith on 3/2/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class FcmMessagingService {
    
    func onMessageReceived(ntf: [AnyHashable : Any]) {
        let json = JSON(ntf)
        let msg = json["message"].stringValue
        let metadata = json["metadata"].stringValue
        self.handleMessage(source: "FCM", message: msg, metadata: metadata)
    }
    
    func handleMessage(source: String, message: String, metadata: String){
        if let _ = DcidrApplication.getInstance().getUserCache().getPref("userId") {
            self.parseAndNotify(jsonObject: JSON.parse(message), jsonMetadataObject: JSON.parse(metadata), source: source)
        }else {
            print("userId is null. returning")
            return;
        }
    }

    func parseAndNotify(jsonObject: JSON, jsonMetadataObject: JSON, source: String) {
        if(jsonObject["GROUP"].exists()){
            let groupFcmNtfHandler = GroupFcmNtfHandler(jsonMetadataObject: jsonMetadataObject, source: source)
            groupFcmNtfHandler.handleNtf(jsonObject: jsonObject)
        }
        if(jsonObject["EVENT"].exists()){
            let eventFcmNtfHandler = EventFcmNtfHandler(jsonMetadataObject: jsonMetadataObject, source: source)
            eventFcmNtfHandler.handleNtf(jsonObject: jsonObject)
        }
        if(jsonObject["FRIEND"].exists()){
            let friendFcmNtfHandler = FriendFcmNtfHandler(jsonMetadataObject: jsonMetadataObject, source: source)
            friendFcmNtfHandler.handleNtf(jsonObject: jsonObject)
        }
//
//        if (jsonObject.has("GROUP")) {
//        if (BuildConfig.DEBUG){Log.i(TAG, "[parseAndNotify] Received data for GROUP");}
//        GroupFcmNtfHandler groupFcmNtfHandler = new GroupFcmNtfHandler(getBaseContext(), jsonMetadataObject, source);
//        groupFcmNtfHandler.handleNtf(jsonObject);
//        } else if (jsonObject.has("EVENT")) {
//        if (BuildConfig.DEBUG){Log.i(TAG, "[parseAndNotify] Received data for EVENT");}
//        EventFcmNtfHandler eventFcmNtfHandler = new EventFcmNtfHandler(getBaseContext(), jsonMetadataObject, source);
//        eventFcmNtfHandler.handleNtf(jsonObject);
//        }else if(jsonObject.has("FRIEND")){
//        if (BuildConfig.DEBUG){Log.i(TAG, "[parseAndNotify] Received data for FRIEND");}
//        FriendFcmNtfHandler friendFcmNtfHandler = new FriendFcmNtfHandler(getBaseContext(), jsonMetadataObject, source);
//        friendFcmNtfHandler.handleNtf(jsonObject);
//        }else if (jsonObject.has("CHWEET")) {
//        if (BuildConfig.DEBUG){Log.i(TAG, "[parseAndNotify] Received data for CHWEET");}
//        EventFcmNtfHandler eventFcmNtfHandler = new EventFcmNtfHandler(getBaseContext(), jsonMetadataObject, source);
//        eventFcmNtfHandler.handleNtf(jsonObject);
//        }else{
//        if (BuildConfig.DEBUG){Log.e(TAG, "[parseAndNotify] Received data for unknown category");}
//        }
    }
}

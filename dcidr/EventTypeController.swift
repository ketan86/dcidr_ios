//
//  EventTypeController.swift
//  dcidr
//
//  Created by John Smith on 12/30/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class EventTypeContainer {
    fileprivate var mEventTypeDict: Dictionary<Int64, BaseEventType>!
    fileprivate var mEventTypeList: Array<BaseEventType>!
    init(){
        self.mEventTypeDict = Dictionary<Int64, BaseEventType>()
        self.mEventTypeList = Array<BaseEventType>()
    }
    
    func populateEventType(_ jsonEventTypeArray: JSON) {
        if let jsonEventTypes = jsonEventTypeArray.array {
            for jsonEventType in jsonEventTypes {
                print(jsonEventType)
                // get eventType 
                if jsonEventType["eventType"].exists() {
                    if(jsonEventType["eventType"].stringValue.lowercased() == "unknown") {
                        continue
                    }
                    let className = DcidrConstant.APP_PACKAGE_PATH + jsonEventType["eventType"].stringValue.capitalized + "EventType"
                    // dymanic mapping to class based on eventType
                    if let aClass = NSClassFromString(className) as? BaseEventType.Type {
                        let obj = aClass.init()
                        obj.populateMe(jsonEventType)
                        self.mEventTypeDict[obj.getEventTypeId()] = obj
                    }else {
                        print(className + " class not found")
                    }
                    
                }else {
                    print("event type is missing")
                }
            }
        }else {
            print("error parsing json")
        }
    }
    
    func getEventTypeList() -> Array<BaseEventType> {
        self.refreshEventTypeList()
        return self.mEventTypeList
    }
    
    func refreshEventTypeList(){
        self.mEventTypeList.removeAll()
        for baseEventType:BaseEventType in self.mEventTypeDict.values {
            self.mEventTypeList.append(baseEventType)
        }
        // TODO need to implement sorting
    }
    
    
    func clearEventTypeDict(){
        self.mEventTypeDict.removeAll()
    }
    
    func getEventTypeDict() -> Dictionary<Int64, BaseEventType>{
        return self.mEventTypeDict
    }
    
    func clear(){
        self.mEventTypeDict.removeAll()
    }
}

//
//  EventContainer.swift
//  dcidr
//
//  Created by John Smith on 12/30/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class EventContainer {
    fileprivate var mBaseEventWrapperDict: Dictionary<Int64, BaseEventWrapper>!
    fileprivate var mBaseEventList: Array<BaseEvent>!
    fileprivate var mBaseGroup: BaseGroup!
    fileprivate var mEventSortKey: BaseEvent.EventSortKey!
    
    init(){
        self.mBaseEventWrapperDict = Dictionary<Int64, BaseEventWrapper>()
        self.mBaseEventList = Array<BaseEvent>()
        self.mEventSortKey = BaseEvent.EventSortKey.EVENT_LAST_MODIFIED_TIME
    }
    
    fileprivate class BaseEventWrapper {
        fileprivate var mIsSearchedResult: Bool = false
        fileprivate var mBaseEvent : BaseEvent!
        
        required init(baseEvent: BaseEvent){
            self.mBaseEvent = baseEvent
        }
        
        func setIsSearchedResult(_ isSearchedResult: Bool){
            self.mIsSearchedResult = isSearchedResult
        }
        func getIsSearchedResult() -> Bool {
            return self.mIsSearchedResult
        }
        
        func getBaseEvent() -> BaseEvent {
            return self.mBaseEvent
        }

        
    }

    enum TypeOfResult {
        case SEARCHED, SCROLLED, ALL
    }
    

    func populateEvents(_ jsonEventArray: JSON) {
        if let jsonEvents = jsonEventArray.array {
            for jsonEvent in jsonEvents {
                if(self.mBaseEventWrapperDict[jsonEvent["eventId"].int64Value] != nil){
                    self.mBaseEventWrapperDict[jsonEvent["eventId"].int64Value]!.setIsSearchedResult(false)
                    self.mBaseEventWrapperDict[jsonEvent["eventId"].int64Value]!.getBaseEvent().populateMe(jsonEvent)
                    continue
                }
                self.populateEvent(jsonEvent)
            }
        }else {
            print("error parsing json")
        }
    }
    
    func populateEvent(_ jsonEvent: JSON) {
        
        if jsonEvent["eventTypeId"].exists() {
            let eventType = String(describing: BaseEvent.EventType(rawValue: jsonEvent["eventTypeId"].intValue)!)
            let className = DcidrConstant.APP_PACKAGE_PATH + eventType.capitalized + "Event"
            // dymanic mapping to class based on eventType
            if let aClass = NSClassFromString(className) as? BaseEvent.Type {
                let obj: BaseEvent = aClass.init()
                obj.setBaseGroup(self.mBaseGroup)
                obj.setEventSortKey(self.mEventSortKey)
                obj.populateMe(jsonEvent)
                if(obj.checkIfExpired()){
                    obj.setEventLastModifiedTime(obj.getEventLastModifiedTime() - Int64.max)
                }
                
                let baseEventWrapper : BaseEventWrapper = BaseEventWrapper(baseEvent: obj)
                baseEventWrapper.setIsSearchedResult(false)
                self.mBaseEventWrapperDict[baseEventWrapper.getBaseEvent().getEventId()] =  baseEventWrapper
                
            }else {
                print(className + " class not found")
            }
        }else {
            print("event  is missing")
        }

    }
    
    func setSortKey(key: BaseEvent.EventSortKey) {
        self.mEventSortKey = key
    }
    
    func setBaseGroup(_ baseGroup: BaseGroup) {
        self.mBaseGroup = baseGroup
    }
    
    func populateEvent(_ baseEvent: BaseEvent, isSearchedResult: Bool){
        let baseEventWrapper : BaseEventWrapper = BaseEventWrapper(baseEvent: baseEvent)
        baseEventWrapper.setIsSearchedResult(isSearchedResult)
        mBaseEventWrapperDict[baseEventWrapper.getBaseEvent().getEventId()]  = baseEventWrapper
    }
    
    func populateEvents(_ arrayList: Array<BaseEvent>, isSearchedResult: Bool){
        for baseEvent in arrayList {
            if(isSearchedResult) {
                // if results are coming as a searched results, we do not want to override the existing baseGroup in mBaseGroupWrapperMap
                // because doing so will set that baseGroup as SEARCHED group and it will destroy the SCROLL state
                if(self.mBaseEventWrapperDict[baseEvent.getEventId()] == nil){
                    let baseEventWrapper : BaseEventWrapper = BaseEventWrapper(baseEvent: baseEvent)
                    baseEventWrapper.setIsSearchedResult(isSearchedResult)
                    mBaseEventWrapperDict[baseEventWrapper.getBaseEvent().getEventId()]  = baseEventWrapper
                }
            }else {
                let baseEventWrapper : BaseEventWrapper = BaseEventWrapper(baseEvent: baseEvent)
                baseEventWrapper.setIsSearchedResult(isSearchedResult)
                mBaseEventWrapperDict[baseEventWrapper.getBaseEvent().getEventId()]  = baseEventWrapper
            }
        }
    }
    
    func getBaseEvent(_ eventId: Int64) -> BaseEvent? {
        if (self.mBaseEventWrapperDict[eventId] == nil) {
            return nil
        } else {
            return self.mBaseEventWrapperDict[eventId]!.getBaseEvent()
        }
    }
    
    func deleteEvents(_ typeOfResult: TypeOfResult){
        for baseEventWrapper  in self.mBaseEventWrapperDict.values {
            if(typeOfResult == TypeOfResult.SEARCHED) {
                if (baseEventWrapper.getIsSearchedResult()) {
                    self.mBaseEventWrapperDict.removeValue(forKey: baseEventWrapper.getBaseEvent().getEventId())
                }
            }else if(typeOfResult == TypeOfResult.SCROLLED){
                if(!baseEventWrapper.getIsSearchedResult()){
                    self.mBaseEventWrapperDict.removeValue(forKey: baseEventWrapper.getBaseEvent().getEventId())
                }
            }else {
                self.mBaseEventWrapperDict.removeValue(forKey: baseEventWrapper.getBaseEvent().getEventId())
            }
        }
    }
    
    func refreshEventList(_ typeOfResult: TypeOfResult){
        // TODO need to return list sorted by last modified time
        self.mBaseEventList.removeAll()
        let baseEventWrapperArrayList : Array<BaseEventWrapper> =  Array<BaseEventWrapper>(self.mBaseEventWrapperDict.values)
        
        var arrayList : Array<BaseEvent>  = Array<BaseEvent>();
        for baseEventWrapper in baseEventWrapperArrayList {
            if(typeOfResult == TypeOfResult.SEARCHED) {
                if (baseEventWrapper.getIsSearchedResult()) {
                    arrayList.append(baseEventWrapper.getBaseEvent())
                }
            }else if(typeOfResult == TypeOfResult.SCROLLED){
                if(!baseEventWrapper.getIsSearchedResult()){
                    arrayList.append(baseEventWrapper.getBaseEvent())
                }
            }else {
                arrayList.append(baseEventWrapper.getBaseEvent())
            }
        }
        
        //Collections.sort(arrayList);
        self.mBaseEventList.append(contentsOf: arrayList)
    }
    
    func getEventList(_ typeOfResult: TypeOfResult) -> Array<BaseEvent> {
        self.refreshEventList(typeOfResult);
        return self.mBaseEventList
    }
    
    func releaseMemory(){
        clear()
    }
    
    func clear(){
        for baseEvent in self.mBaseEventList {
            baseEvent.getChildEventsContainer().mBaseEventList.removeAll()
            baseEvent.releaseMemory();
        }
        self.mBaseEventList.removeAll()
        self.mBaseEventWrapperDict.removeAll()
    
    }

}

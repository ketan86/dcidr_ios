//
//  UserEventStatusContainer.swift
//  dcidr
//
//  Created by John Smith on 1/20/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class UserEventStatusContainer {
    
    fileprivate var mUserEventStatusArray : Array<UserEventStatus>!
    fileprivate var mGroupId: Int64!
    init(){
        self.mUserEventStatusArray = Array<UserEventStatus>()
    }
    func setGroupId(_ groupId: Int64) {
        self.mGroupId = groupId
    }
    func populdateMe(_ jsonObj : JSON) {
        let userId = jsonObj["userId"].int64Value
        if(self.hasUserEventStatusObj(userId: userId)){
            return
        }
        let eventId = jsonObj["eventId"].int64Value
        let eventTypeId = jsonObj["eventTypeId"].intValue
        let userEventStatus = UserEventStatus(userId, groupId: self.mGroupId, eventId: eventId, eventType: BaseEvent.EventType(rawValue: eventTypeId)!)
        userEventStatus.setEventStatusTypeId(jsonObj["eventStatusTypeId"].intValue)
        self.mUserEventStatusArray.append(userEventStatus)
    }
    
    func populateMe(_ jsonUserEventStatusArray: JSON) {
        if let jsonUserEventStatuses = jsonUserEventStatusArray.array {
            for jsonUserEventStatus in jsonUserEventStatuses {
                self.populdateMe(jsonUserEventStatus)
            }
        }
    }

    func getUserToStatusDict() -> Dictionary<UserEventStatus.EventStatusType, Int>  {
        var statusDict = Dictionary<UserEventStatus.EventStatusType, Int>()
        for userEventStatus in self.mUserEventStatusArray {
            if(statusDict[userEventStatus.getEventStatusType()] != nil) {
                statusDict[userEventStatus.getEventStatusType()] = statusDict[userEventStatus.getEventStatusType()]! + 1
            }else {
                statusDict[userEventStatus.getEventStatusType()] =  1
            }
        }
        
        if(statusDict[UserEventStatus.EventStatusType.ACCEPTED] == nil){
            statusDict[UserEventStatus.EventStatusType.ACCEPTED] = 0
        }
        if(statusDict[UserEventStatus.EventStatusType.DECLINED] == nil){
            statusDict[UserEventStatus.EventStatusType.DECLINED] =  0
        }
        
        return statusDict
    }

    func getCurrentUserEventStatusObj() -> UserEventStatus? {
        print(self.mUserEventStatusArray)
        for userEventStatus in self.mUserEventStatusArray {
            if (userEventStatus.getUserIdStr() == DcidrApplication.getInstance().getUser().userId){
                return userEventStatus
            }
        }
        return nil
    }

    func getUserEventStatusArray() ->  Array<UserEventStatus>{
        return self.mUserEventStatusArray
    }

    func clear(){
        self.mUserEventStatusArray.removeAll()
    }

    func getUserEventStatusObj(userId: Int64) -> UserEventStatus? {
        for userEventStatus in self.mUserEventStatusArray{
            if (userEventStatus.getUserId() == userId){
                return userEventStatus
            }
        }
        return nil
    }

    func hasUserEventStatusObj(userId: Int64) -> Bool{
        for userEventStatus in self.mUserEventStatusArray {
            if (userEventStatus.getUserId() == userId){
                return true
            }
        }
        return false
    }
}

//
//  UserEventStatus.swift
//  dcidr
//
//  Created by John Smith on 1/20/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
class UserEventStatus {
    
    fileprivate let mUser: User!
    fileprivate let mGroupId: Int64!
    fileprivate let mEventId: Int64!
    fileprivate var mEventStatusType: EventStatusType!
    fileprivate let mEventType: BaseEvent.EventType!
    
    enum EventStatusType: Int {
        case PENDING = 0, ACCEPTED, DECLINED
        
        static func enumFromString(_ str:String) -> EventStatusType? {
            var i = 0
            while let item = EventStatusType(rawValue: i) {
                if String(describing: item) == str.uppercased() {
                    return item
                }
                i += 1
            }
            return nil
        }
    }
    
    init(_ userId: Int64, groupId: Int64 , eventId: Int64, eventType: BaseEvent.EventType){
        self.mUser = User()
        self.mUser.userId = String(userId)
        self.mGroupId = groupId
        self.mEventId = eventId
        self.mEventType = eventType
        // initialize with pending status type
        self.mEventStatusType = EventStatusType.PENDING;
    }
    func getUserId() -> Int64 {
        return Int64(mUser.userId)!
    }
    func getUserObj() -> User{
        return self.mUser
    }
    func getGroupId() -> Int64 {
        return self.mGroupId
    }
    func getEventId() -> Int64 {
        return self.mEventId
    }
    func getEventType() -> BaseEvent.EventType {
        return self.mEventType
    }
    
    func getUserIdStr() -> String{
        print(mUser.userId)
        return mUser.userId
    }
    func getGroupIdStr() -> String{
        return String(self.mGroupId)
    }
    func getEventIdStr() -> String{
        return String(self.mEventId)
    }
    func getEventTypeStr() -> String {
        return String(describing: mEventType!)
    }
    
    func getEventStatusType() -> EventStatusType{
        return mEventStatusType
    }
    func setEventStatusTypeId(_ id: Int){
        if(id == 0){
            self.mEventStatusType = EventStatusType.PENDING
        }else if(id == 1){
            self.mEventStatusType = EventStatusType.ACCEPTED
        }else if(id == 2){
            self.mEventStatusType = EventStatusType.DECLINED
        }else {
            self.mEventStatusType = EventStatusType.PENDING
        }
    }
    
    func setEventStatusType(_ eventStatusType: UserEventStatus.EventStatusType){
        self.mEventStatusType = eventStatusType
    }
    
    func getUserEventDictRemote() -> Dictionary<String, String> {
        var userEventDict: Dictionary<String, String> = Dictionary<String, String>()
        userEventDict["eventStatusType"] =  String(describing: self.mEventStatusType!)
        return userEventDict
    }

}

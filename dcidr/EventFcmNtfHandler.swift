//
//  EventFcmNtfHandler.swift
//  dcidr
//
//  Created by John Smith on 3/25/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class EventFcmNtfHandler : BaseFcmNtfHandler {
    
    fileprivate var mEventId: Int64!
    fileprivate var mParentEventId : Int64!
    fileprivate var mParentEventTypeId: Int64!
    fileprivate var mGroupId: Int64!
    fileprivate var mSrcUserId: Int64!
    override init(jsonMetadataObject: JSON, source: String) {
        super.init(jsonMetadataObject: jsonMetadataObject, source: source)
    }
    
    func getParentEventIdForFetch() -> Int64{
        var eventId = Int64(-1)
        if(self.mParentEventId != nil && self.mParentEventId == -1 ) {
            eventId = self.mEventId
        }else {
            eventId = self.mParentEventId
        }
        return eventId
    }

    
    func handleNtf(jsonObject: JSON) {
        var eventJsonObj = jsonObject["EVENT"]
        self.mGroupId = eventJsonObj["groupId"].int64Value
        self.mEventId = eventJsonObj["eventId"].int64Value
        self.mParentEventId = eventJsonObj["parentEventId"].int64Value
        if(eventJsonObj["userId"].exists()) {
            mSrcUserId = eventJsonObj["userId"].int64Value
        }else {
            print("[handleNtf] srcUserId is null")
        }
        if (self.mNotificationCode == NotificationCodes.EVENT_CREATE_NTF_CODE) {
            eventJsonObj["createdByName"] = eventJsonObj["srcUserName"]
            self.handleEventCreateNtf(jsonObject: eventJsonObj)
        }else if(self.mNotificationCode == NotificationCodes.EVENT_STATUS_NTF_CODE) {
            self.handleEventStatusNtf(jsonObject: eventJsonObj)
        }else if(self.mNotificationCode == NotificationCodes.EVENT_BUZZ_NTF_CODE) {
            self.handleEventBuzzNtf(jsonObject: eventJsonObj)
        }else if(self.mNotificationCode == NotificationCodes.EVENT_WILL_EXPIRE_NTF_CODE) {
            self.handleEventWillExpireNtf(jsonObject: eventJsonObj)
        }else if(self.mNotificationCode == NotificationCodes.EVENT_HAS_EXPIRED_NTF_CODE) {
            self.handleEventHasExpiredNtf(jsonObject: eventJsonObj)
        }else if(self.mNotificationCode == NotificationCodes.EVENT_IMAGE_CREATE_NTF_CODE) {
            self.handleImageCreateNtf(jsonObject: eventJsonObj)
        }else {
            print("[handleNtf] Invalid notification code")
        }
    }
    
    
    func handleImageCreateNtf(jsonObject : JSON) {
        if let baseGroup = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId) {
            // check if event is child or parentEvent
            if (self.mParentEventId == -1) {
                if let _ = baseGroup.getEventContainer().getBaseEvent(self.mEventId) {
                    self.eventImageCreateNtf(jsonObject: jsonObject)
                } else {
                    self.fetchEventRefreshActivitiesEventImageCreateNtf(jsonObject: jsonObject)
                }
            } else {
                if let _ = baseGroup.getEventContainer().getBaseEvent(self.mParentEventId) {
                    self.eventImageCreateNtf(jsonObject: jsonObject)
                }else {
                    self.fetchEventRefreshActivitiesEventImageCreateNtf(jsonObject: jsonObject)
                }
            }
        }else {
            self.fetchGroupEventRefreshActivitiesEventImageCreateNtf(jsonObject: jsonObject)
        }
    }
    
    
    func fetchGroupEventRefreshActivitiesEventImageCreateNtf(jsonObject: JSON){
        let groupFetchHelper = GroupFetchHelper()
        groupFetchHelper.fetchGroup(groupIdStr: String(self.mGroupId), fetchSuccessCb: {
            (groupJsonObject) in
            DcidrApplication.getInstance().getGlobalGroupContainer().populateGroup(groupJsonObject);
            self.fetchEventRefreshActivitiesEventImageCreateNtf(jsonObject: jsonObject)
        }, fetchFailureCb: {
            print("Error getting group")
        })
    }
    
    func fetchEventRefreshActivitiesEventImageCreateNtf(jsonObject: JSON){
        let eventId = getParentEventIdForFetch()
        if let _ = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(mGroupId)!.getEventContainer().getBaseEvent(eventId) {
            let eventFetchHelper = EventFetchHelper()
            eventFetchHelper.fetchEvent(groupIdStr: String(self.mGroupId), eventIdStr: String(eventId), fetchSuccessCb: {
                () in
                self.eventImageCreateNtf(jsonObject: jsonObject)
            }, fetchFailureCb: {
                print("Error getting event")
            })
        }
    }

    
    func eventImageCreateNtf(jsonObject : JSON) {
        
        var eventId: String? = nil
        
        if(self.mParentEventId == -1) {
            eventId = String(self.mEventId)
        }else {
            eventId = String(self.mParentEventId)
        }
        
        let keyValue: [String: Any] = [
            "viewController" : "EventTimelineViewController",
            "data" : [
                "groupId" : String(self.mGroupId),
                "eventId" : eventId!,
                "MSG" : jsonObject
            ]
        ]
        
        // get groupName
        let groupName = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId)!.groupName
        let eventName = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId)!.getEventContainer().getBaseEvent(self.mEventId)!.getEventName()
        

        self.sendNotification(userId: self.mSrcUserId, title: "Dcidr Notification", body: "Image added in event " + eventName + " under group " + groupName + " by " + self.mJsonMetadataObj["srcUserName"].stringValue + ".", keyValue: keyValue)


    }

    func handleEventHasExpiredNtf(jsonObject : JSON) {
        if let baseGroup = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId) {
            // check if event is child or parentEvent
            if (self.mParentEventId == -1) {
                if let _ = baseGroup.getEventContainer().getBaseEvent(self.mEventId) {
                    self.eventHasExpiredNtf(jsonObject: jsonObject)
                } else {
                    self.fetchEventRefreshActivitiesEventHasExpiredNtf(jsonObject: jsonObject)
                }
            } else {
                if let parentEvent = baseGroup.getEventContainer().getBaseEvent(self.mParentEventId) {
                    if let _ = parentEvent.getChildEventsContainer().getBaseEvent(self.mEventId) {
                        self.eventExpireNtf(jsonObject: jsonObject)
                    } else {
                        self.fetchEventRefreshActivitiesEventHasExpiredNtf(jsonObject: jsonObject)
                    }
                }else {
                    self.fetchEventRefreshActivitiesEventHasExpiredNtf(jsonObject: jsonObject)
                }
            }
        }else {
            self.fetchGroupEventRefreshActivitiesEventHasExpiredNtf(jsonObject: jsonObject)
        }
        
    }
    
    
    
    
    func eventHasExpiredNtf(jsonObject: JSON){
        let totalMembersCount = jsonObject["totalMembersCount"].intValue
        let acceptedMembersCount = jsonObject["acceptedMembersCount"].intValue
        var hasMajority: Bool = false
        if(acceptedMembersCount == totalMembersCount) {
            hasMajority = true
            // add to calender
        }
        
        var eventId: String? = nil
        
        if(self.mParentEventId == -1) {
            eventId = String(self.mEventId)
        }else {
            eventId = String(self.mParentEventId)
        }
        
        let keyValue: [String: Any] = [
            "viewController" : "EventTimelineViewController",
            "data" : [
                "groupId" : String(self.mGroupId),
                "eventId" : eventId
            ]
        ]
        
        // get groupName
        let groupName = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId)!.groupName
        let eventName = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId)!.getEventContainer().getBaseEvent(self.mEventId)!.getEventName()
        
        // send notification
        if(hasMajority) {
            self.sendNotification(userId: self.mSrcUserId, title: "Dcidr Notification", body: eventName + " in " + groupName + " has expired with majority. Added to calender.", keyValue: keyValue)
        }else {
            self.sendNotification(userId: self.mSrcUserId, title: "Dcidr Notification", body: eventName + " in " + groupName + " has expired.", keyValue: keyValue)
        }
    }
    
    func fetchGroupEventRefreshActivitiesEventHasExpiredNtf(jsonObject: JSON){
        let groupFetchHelper = GroupFetchHelper()
        groupFetchHelper.fetchGroup(groupIdStr: String(self.mGroupId), fetchSuccessCb: {
            (groupJsonObject) in
            DcidrApplication.getInstance().getGlobalGroupContainer().populateGroup(groupJsonObject);
            self.fetchEventRefreshActivitiesEventHasExpiredNtf(jsonObject: jsonObject)
        }, fetchFailureCb: {
            print("Error getting group")
        })
    }
    
    func fetchEventRefreshActivitiesEventHasExpiredNtf(jsonObject: JSON){
        let eventId = getParentEventIdForFetch()
        if let _ = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(mGroupId)!.getEventContainer().getBaseEvent(eventId) {
            let eventFetchHelper = EventFetchHelper()
            eventFetchHelper.fetchEvent(groupIdStr: String(self.mGroupId), eventIdStr: String(eventId), fetchSuccessCb: {
                () in
                self.eventHasExpiredNtf(jsonObject: jsonObject)
            }, fetchFailureCb: {
                print("Error getting event")
            })
        }
    }

    
    func handleEventWillExpireNtf(jsonObject : JSON) {
        
        if let baseGroup = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId) {
            // check if event is child or parentEvent
            if (self.mParentEventId == -1) {
                if let _ = baseGroup.getEventContainer().getBaseEvent(self.mEventId) {
                    self.eventExpireNtf(jsonObject: jsonObject)
                } else {
                    self.fetchEventRefreshActivitiesEventExpireNtf(jsonObject: jsonObject)
                }
            } else {
                if let parentEvent = baseGroup.getEventContainer().getBaseEvent(self.mParentEventId) {
                    if let _ = parentEvent.getChildEventsContainer().getBaseEvent(self.mEventId) {
                        self.eventExpireNtf(jsonObject: jsonObject)
                    } else {
                        self.fetchEventRefreshActivitiesEventExpireNtf(jsonObject: jsonObject)
                    }
                }else {
                    self.fetchEventRefreshActivitiesEventExpireNtf(jsonObject: jsonObject)
                }
            }
        }else {
            self.fetchGroupEventRefreshActivitiesEventExpireNtf(jsonObject: jsonObject)
        }
    }
    
    
    func eventExpireNtf(jsonObject : JSON) {
        var eventId: String? = nil
        
        if(self.mParentEventId == -1) {
            eventId = String(self.mEventId)
        }else {
            eventId = String(self.mParentEventId)
        }
        
        let keyValue: [String: Any] = [
            "viewController" : "EventTimelineViewController",
            "data" : [
                "groupId" : String(self.mGroupId),
                "eventId" : eventId
            ]
        ]
        
        // get groupName
        let groupName = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId)!.groupName
        let eventName = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId)!.getEventContainer().getBaseEvent(self.mEventId)!.getEventName()
        
        self.sendNotification(userId: self.mSrcUserId, title: "Dcidr Notification", body: eventName + " in " +
            groupName + " will expire in " + String(self.mJsonMetadataObj["eventExpiryInterval"].intValue/60) + " minutes", keyValue: keyValue)
    }
    
    func fetchGroupEventRefreshActivitiesEventExpireNtf(jsonObject: JSON){
        let groupFetchHelper = GroupFetchHelper()
        groupFetchHelper.fetchGroup(groupIdStr: String(self.mGroupId), fetchSuccessCb: {
            (groupJsonObject) in
            DcidrApplication.getInstance().getGlobalGroupContainer().populateGroup(groupJsonObject);
            self.fetchEventRefreshActivitiesEventExpireNtf(jsonObject: jsonObject)
        }, fetchFailureCb: {
            print("Error getting group")
        })
    }
    
    func fetchEventRefreshActivitiesEventExpireNtf(jsonObject: JSON){
        let eventId = getParentEventIdForFetch()
        if let _ = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(mGroupId)!.getEventContainer().getBaseEvent(eventId) {
            let eventFetchHelper = EventFetchHelper()
            eventFetchHelper.fetchEvent(groupIdStr: String(self.mGroupId), eventIdStr: String(eventId), fetchSuccessCb: {
                () in
                self.eventExpireNtf(jsonObject: jsonObject)
            }, fetchFailureCb: {
                print("Error getting event")
            })
        }
    }
    
    func handleEventBuzzNtf(jsonObject : JSON) {
        if let baseGroup = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId) {
            if (self.mParentEventId == -1) {
                if let _ = baseGroup.getEventContainer().getBaseEvent(self.mEventId) {
                    self.buzzUserNtf(jsonObject: jsonObject)
                } else {
                    self.fetchEventRefreshActivitiesBuzzUserNtf(jsonObject: jsonObject)
                }
            } else {
                if let parentEvent = baseGroup.getEventContainer().getBaseEvent(self.mParentEventId) {
                    if let _ = parentEvent.getChildEventsContainer().getBaseEvent(self.mEventId) {
                        self.buzzUserNtf(jsonObject:jsonObject)
                    } else {
                        self.fetchEventRefreshActivitiesBuzzUserNtf(jsonObject: jsonObject)
                    }
                }else {
                    self.fetchEventRefreshActivitiesBuzzUserNtf(jsonObject: jsonObject)
                }
            }
        }else {
            self.fetchGroupEventRefreshActivitiesBuzzUserNtf(jsonObject: jsonObject)
        }
    }
    
    
    func fetchGroupEventRefreshActivitiesBuzzUserNtf(jsonObject: JSON){
        let groupFetchHelper = GroupFetchHelper()
        groupFetchHelper.fetchGroup(groupIdStr: String(self.mGroupId), fetchSuccessCb: {
            (groupJsonObject) in
            DcidrApplication.getInstance().getGlobalGroupContainer().populateGroup(groupJsonObject);
            self.fetchEventRefreshActivitiesBuzzUserNtf(jsonObject: jsonObject)
        }, fetchFailureCb: {
            print("Error getting group")
        })
    }
    
    func fetchEventRefreshActivitiesBuzzUserNtf(jsonObject: JSON){
        let eventId = getParentEventIdForFetch()
        if let _ = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(mGroupId)!.getEventContainer().getBaseEvent(eventId) {
            let eventFetchHelper = EventFetchHelper()
            eventFetchHelper.fetchEvent(groupIdStr: String(self.mGroupId), eventIdStr: String(eventId), fetchSuccessCb: {
                () in
                self.buzzUserNtf(jsonObject: jsonObject)
            }, fetchFailureCb: {
                print("Error getting event")
            })
        }
    }
    
    func buzzUserNtf(jsonObject: JSON){
        var eventId: String? = nil
        
        if(self.mParentEventId == -1) {
            eventId = String(self.mEventId)
        }else {
            eventId = String(self.mParentEventId)
        }
        
        let keyValue: [String: Any] = [
            "viewController" : "EventTimelineViewController",
            "data" : [
                "groupId" : String(self.mGroupId),
                "eventId" : eventId
            ]
        ]
        
        // get groupName
        let groupName = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId)!.groupName
        let eventName = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId)!.getEventContainer().getBaseEvent(self.mEventId)!.getEventName()

        self.sendNotification(userId: self.mSrcUserId, title: "Dcidr Notification", body: self.mJsonMetadataObj["srcUserName"].stringValue + " just buzzed you for an activity " +  eventName + " for group " + groupName, keyValue: keyValue)
    
    }
    
    
    
    func handleEventStatusNtf(jsonObject: JSON) {
        let eventStatusType: String = jsonObject["eventStatusType"].stringValue
        if let baseGroup = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(self.mGroupId) {
            if (self.mParentEventId == -1) {
                if let baseEvent = baseGroup.getEventContainer().getBaseEvent(self.mEventId) {
                    // change user event status for the event that user has accepted or declined
                    // update last modified time of parent event for sorting
                    baseEvent.setEventLastModifiedTime(Utils.currentTimeMillis())
                    
                    if let userEventStatus = baseEvent.getUserEventStatusContainer().getUserEventStatusObj(userId: self.mSrcUserId) {
                        userEventStatus.setEventStatusType(UserEventStatus.EventStatusType.enumFromString(eventStatusType)!)
                    }
                    // for all child events
                    for childEvent in baseEvent.getChildEventsContainer().getEventList(EventContainer.TypeOfResult.ALL) {
                        if let childEventUserEventStatus = childEvent.getUserEventStatusContainer().getUserEventStatusObj(userId: self.mSrcUserId) {
                            childEventUserEventStatus.setEventStatusType(UserEventStatus.EventStatusType.DECLINED)
                        }
                    }
                    eventStatusChangeNtf(jsonObject: jsonObject);
                } else {
                    fetchEventRefreshActivitiesEventStatusChangeNtf(jsonObject: jsonObject)
                }
                
            }else {
                fetchEventRefreshActivitiesEventStatusChangeNtf(jsonObject: jsonObject)
            }
        }else {
            fetchEventRefreshActivitiesEventStatusChangeNtf(jsonObject: jsonObject)

        }
    }
    
    func fetchGroupEventRefreshActivitiesEventStatusChangeNtf(jsonObject: JSON){
        let groupFetchHelper = GroupFetchHelper()
        groupFetchHelper.fetchGroup(groupIdStr: String(self.mGroupId), fetchSuccessCb: {
        (groupJsonObject) in
            DcidrApplication.getInstance().getGlobalGroupContainer().populateGroup(groupJsonObject);
            self.fetchEventRefreshActivitiesEventStatusChangeNtf(jsonObject: jsonObject)
        }, fetchFailureCb: {
            print("Error getting group")
        })
    }
    
    func fetchEventRefreshActivitiesEventStatusChangeNtf(jsonObject: JSON){
        let eventId = getParentEventIdForFetch()
        if let _ = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(mGroupId)!.getEventContainer().getBaseEvent(eventId) {
            let eventFetchHelper = EventFetchHelper()
            eventFetchHelper.fetchEvent(groupIdStr: String(self.mGroupId), eventIdStr: String(eventId), fetchSuccessCb: {
                () in
                self.eventStatusChangeNtf(jsonObject: jsonObject)
            }, fetchFailureCb: {
                print("Error getting event")
            })
        }
    }

    func eventStatusChangeNtf(jsonObject: JSON){
        var eventId: String? = nil
        
        if(self.mParentEventId == -1) {
            eventId = String(self.mEventId)
        }else {
            eventId = String(self.mParentEventId)
        }
        
        let keyValue: [String: Any] = [
            "viewController" : "EventTimelineViewController",
            "data" : [
                "groupId" : String(self.mGroupId),
                "eventId" : eventId
            ]
        ]
        self.sendNotification(userId: self.mSrcUserId, title: "Dcidr Notification", body: jsonObject["eventName"].stringValue + " activity " + jsonObject["eventStatusType"].stringValue.lowercased() + " by " + self.mJsonMetadataObj["srcUserName"].stringValue, keyValue: keyValue)
    }
    
    func handleEventCreateNtf(jsonObject: JSON){
        let globalGrouContainer = DcidrApplication.getInstance().getGlobalGroupContainer()
        if let baseGroup = globalGrouContainer.getBaseGroup(self.mGroupId) {
            if(jsonObject["groupLastModifiedTime"].exists()) {
                baseGroup.groupLastModifiedTime = jsonObject["groupLastModifiedTime"].int64Value
            }
            if(self.mParentEventId == -1) {
                baseGroup.getEventContainer().populateEvent(jsonObject)
                baseGroup.incrementTotalEventCount()
                baseGroup.unreadEventCount += 1
                self.createEventNtf(jsonObject: jsonObject)
            }else {
                if(self.mEventId != nil) {
                    let eventContainer  = baseGroup.getEventContainer()
                    if let parentEvent = eventContainer.getBaseEvent(self.mParentEventId) {
                        parentEvent.setEventLastModifiedTime(baseGroup.groupLastModifiedTime)
                        parentEvent.getChildEventsContainer().populateEvent(jsonObject)
                        self.createEventNtf(jsonObject: jsonObject)
                    }else {
                        fetchEventRefreshActivitiesCreateEventNtf(jsonObject: jsonObject)
                    }
                    baseGroup.unreadEventCount += 1
                } else {
                    print("EventId can not be null")
                }
            }
        }else {
            self.fetchGroupEventRefreshActivitiesCreateEventNtf(jsonObject: jsonObject)
        }
    }
    
    func fetchGroupEventRefreshActivitiesCreateEventNtf(jsonObject: JSON) {
        let groupFetchHelper = GroupFetchHelper()
        groupFetchHelper.fetchGroup(groupIdStr: String(self.mGroupId), fetchSuccessCb: {
        (groupJsonObject) in
            DcidrApplication.getInstance().getGlobalGroupContainer().populateGroup(groupJsonObject);
            self.fetchEventRefreshActivitiesCreateEventNtf(jsonObject: jsonObject)
        }, fetchFailureCb: {
            print("Error getting group")
        })
        
    }

    func fetchEventRefreshActivitiesCreateEventNtf(jsonObject: JSON) {
        let eventId = getParentEventIdForFetch();
        if let _ = DcidrApplication.getInstance().getGlobalGroupContainer().getBaseGroup(mGroupId)!.getEventContainer().getBaseEvent(eventId) {
            let eventFetchHelper = EventFetchHelper()
            eventFetchHelper.fetchEvent(groupIdStr: String(self.mGroupId), eventIdStr: String(eventId), fetchSuccessCb: {
                () in
                self.createEventNtf(jsonObject: jsonObject)
            }, fetchFailureCb: {
                print("Error getting event")
            })
        }
    }
    
    func createEventNtf(jsonObject: JSON) {
        let keyValue: [String: Any] = [
            "viewController" : "SelectedGroupEventsViewController",
            "data" : [
                "groupId" : String(self.mGroupId)
                ]
            ]
        print(self.mGroupId)
        self.sendNotification(userId: self.mSrcUserId, title: "Dcidr Notification", body: jsonObject["eventName"].stringValue + " activity created under " + self.mJsonMetadataObj["groupName"].stringValue + " by " + self.mJsonMetadataObj["srcUserName"].stringValue, keyValue: keyValue)
    }

}

//
//  BaseEvent.swift
//  dcidr
//
//  Created by John Smith on 12/30/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class BaseEvent : Comparable {
    
    
    enum EventSortKey {
        case EVENT_LAST_MODIFIED_TIME, EVENT_DECIDED_TIME, EVENT_CREATION_TIME, EVENT_ACCEPTED_COUNT
    }

    
    enum EventType: Int {
        case UNKNOWN = -1
        case HIKE = 15
        case FOOD = 16
        case SPORT = 17
        case BIRTHDAY = 18
        case HAPPYHOUR = 19
        case POTLUCK = 20
        case VALENTINE = 21
        case BABYSHOWER = 22
        case CHRISTMAS = 23
        case THANKSGIVING = 24;
        
        static func enumFromString(_ str:String) -> EventType? {
            var i = 15
            while let item = EventType(rawValue: i) {
                print("item  \(String(describing: item))")
                print("string \(str.uppercased())")
                if String(describing: item) == str.uppercased() {
                    return item
                }
                i += 1
            }
            return nil
        }
        
        
    }
    
    class EventAttributeMask {
        private var mEventMask: Int32
        init() {
            mEventMask = 0
        }
        func setEventAttribute(eventAttribute: EventAttribute) {
            var maskVal:Int32 = 1;
            let eventAttr: Int32 = Int32(eventAttribute.rawValue)
            maskVal = maskVal << eventAttr
            mEventMask |= Int32(maskVal);
        }
        func isEventAttributeEditable(eventAttribute: EventAttribute) -> Bool{
            var maskVal: Int32 = 1
            maskVal = maskVal << eventAttribute.rawValue
            if ((self.mEventMask & maskVal) > 0 ) {
                return true
            }
            return false
        }
        func getMask() -> Int32 {
            return self.mEventMask
        }
        func setMask(mask: Int32){
            self.mEventMask = mask
        }
    }

    enum EventAttribute : Int32 {
        case ALLOW_EDITABLE_DIFFERENT_EVENT_TYPES = 0
        case ALLOW_EVENT_PROPOSAL = 1
        case ALLOW_EDITABLE_EVENT_LOCATION = 2
        case ALLOW_EDITABLE_EVENT_TIME = 3
        case ALLOW_RECURRING_EVENT = 4;
        
        static func enumFromString(_ str:String) -> EventAttribute? {
            var i = 0
            while let item = EventAttribute(rawValue: Int32(i)) {
                if String(describing: item) == str {
                    return item
                }
                i += 1
            }
            return nil
        }
    }

    
    fileprivate static var UNDEFINED: Int64  = -1
    fileprivate var mBaseEventType: EventType = EventType.UNKNOWN
    fileprivate var mEventId: Int64 = -1
    fileprivate var mStartTime: Int64 = 0
    fileprivate var mEndTime: Int64 = 0
    fileprivate var mLocationCoordinates: Points? = nil
    fileprivate var mEventType : EventType = EventType.UNKNOWN
    fileprivate var mEventTypeId: Int = -1
    fileprivate var mEventName : String!
    fileprivate var mEventCreationTime: Int64  = 0
    fileprivate var mEventLastModifiedTime : Int64 = 0
    fileprivate var mDecidedTime: Int64 = 0
    fileprivate var mDecided : Bool = false
    fileprivate var mFinished : Bool = false
    fileprivate var mDecideByTime: Int64 = 0
    fileprivate var mLocationName:String? = nil
    fileprivate var mHasExpired: Bool = false
    fileprivate var mEventSortKey: EventSortKey = EventSortKey.EVENT_LAST_MODIFIED_TIME
    fileprivate var mBaseGroup: BaseGroup? = nil
    fileprivate var mUserEventStatusContainer: UserEventStatusContainer!
    fileprivate var mParentEventId : Int64 = -1
    fileprivate var mParentEventType : EventType = EventType.UNKNOWN
    fileprivate var mCreatedByName : String? = nil
    fileprivate var mChildEventsContainer : EventContainer!
    fileprivate var mChweetContainer: ChweetContainer!
    fileprivate var mEventProfilePicUrl: String?  = nil
    fileprivate var mEventProfilePicBase64Str: String? = nil
    fileprivate var mEventProfilePicData: Data? = nil
    fileprivate var mEventNotes: String? = nil
    fileprivate var mEventAttributeMask: EventAttributeMask? = nil
    fileprivate var mDistanceFromCurrentLoc: Double = 0
    fileprivate var mLocationMapImage: UIImage? = nil
    fileprivate var mEventProfilePicFetchDoneCb: (_ imageData: Data) -> () = {
        (imageData : Data) in
    }
    
    
    // comparable protocol implementation
    static func < (lhs: BaseEvent, rhs: BaseEvent) -> Bool {
        if(lhs.getEventSortKey() == EventSortKey.EVENT_ACCEPTED_COUNT) {
            return lhs.getAcceptedMembersCount() < lhs.getAcceptedMembersCount()
        }else {
            return lhs.mEventLastModifiedTime < rhs.mEventLastModifiedTime
        }
    }
    
    static func > (lhs: BaseEvent, rhs: BaseEvent) -> Bool {
        if(lhs.getEventSortKey() == EventSortKey.EVENT_ACCEPTED_COUNT) {
            return lhs.getAcceptedMembersCount() > lhs.getAcceptedMembersCount()
        }else {
            return lhs.mEventLastModifiedTime > rhs.mEventLastModifiedTime
        }
    }
    
    static func == (lhs: BaseEvent, rhs: BaseEvent) -> Bool {
        if(lhs.getEventSortKey() == EventSortKey.EVENT_ACCEPTED_COUNT) {
            return lhs.getAcceptedMembersCount() == lhs.getAcceptedMembersCount()

        }else {
            return lhs.mEventLastModifiedTime == rhs.mEventLastModifiedTime
        }
    }

    
    required init() {
        self.mUserEventStatusContainer = UserEventStatusContainer()
        self.mChildEventsContainer = EventContainer()
        self.mChweetContainer = ChweetContainer()
        self.mEventAttributeMask = EventAttributeMask()
    }
    
    func getEventSortKey () -> EventSortKey {
        return self.mEventSortKey
    }

    func getAcceptedMembersCount() -> Int {
        return self.mUserEventStatusContainer.getUserToStatusDict()[UserEventStatus.EventStatusType.ACCEPTED]!
    }
    
    func getLeader() -> BaseEvent {
        var leaderEvent: BaseEvent!
        var leaderAcceptedCt: Int = self.getAcceptedMembersCount()
        leaderEvent = self
        for childEvent in getChildEventsContainer().getEventList(EventContainer.TypeOfResult.ALL) {
            if (childEvent.getAcceptedMembersCount() > leaderAcceptedCt) {
                leaderEvent = childEvent
                leaderAcceptedCt = childEvent.getAcceptedMembersCount()
            }
        }
        return leaderEvent;
    }
    
    func seEventProfilePicFetchDoneCb( _ cb: @escaping (_ imageData:Data) -> ()) {
        self.mEventProfilePicFetchDoneCb = cb
    }
    
    func getEventProfilePicData() -> Data? {
        return self.mEventProfilePicData
    }

    
    func getDistanceFromCurrentLoc() -> Double {
        return self.mDistanceFromCurrentLoc
    }
//    
//    func  getDistanceFromCurrentLocInMilesStr() -> String{
//    DecimalFormat f = new DecimalFormat("##.00");
//    return String.valueOf(f.format(self.mDistanceFromCurrentLoc * 0.000621371)) + " miles away";
//    }
    
    func setDistanceFromCurrentLoc(_ distanceFromCurrentLoc : Double){
     return self.mDistanceFromCurrentLoc = distanceFromCurrentLoc
    }
    
    func getEventAttributeMask() -> EventAttributeMask{
        return self.mEventAttributeMask!
    }
    

    
    func setLocationMapImage(_ image: UIImage){
        self.mLocationMapImage = image
    }
    func getLocationMapImage() -> UIImage? {
        return self.mLocationMapImage
    }
    
    func getChildEventsContainer() -> EventContainer {
        return self.mChildEventsContainer
    }
    
    func setChildEventsContainer(_ childEventsContainer: EventContainer){
        self.mChildEventsContainer = childEventsContainer
    }
    
    func getChweetContainer() -> ChweetContainer {
        return self.mChweetContainer
    }
    
    func setChweetContainer(chweetContainer: ChweetContainer){
        self.mChweetContainer = chweetContainer
    }
    
    func setEventSortKey(_ key: EventSortKey){
        self.mEventSortKey = key
    }
    
    func setBaseGroup(_ baseGroup: BaseGroup) {
        self.mBaseGroup = baseGroup //if the baseEvent has a link with a baseGroup call this function
    }
    
    func setParentEventId(_ parentEventId: Int64) {
        self.mParentEventId = parentEventId
    }
    
    func setParentEventType(_ parentEventTypeId: EventType) {
        self.mParentEventType = parentEventTypeId
    }
    
    
    func setEventNotes(_ notes: String){
        self.mEventNotes = notes
    }
    
    func getEventNotes() -> String? {
        return self.mEventNotes
    }
    
    func getParentEventId() -> Int64 {
        return self.mParentEventId
    }
    
    func getParentEventType() -> EventType {
        return self.mParentEventType
    }
    
    func getParentEventIdStr() -> String {
        return String(self.mParentEventId)
    }
    
    func getParentEventTypeStr() -> String {
        return String(describing: self.mParentEventType)
    }
    
    func setCreatedByName(_ userName: String) {
        self.mCreatedByName = userName;
    }
    
    func getCreatedByName() -> String? {
        return self.mCreatedByName;
    }
    
    func getBaseGroup() -> BaseGroup? {
        return self.mBaseGroup
    }
    
    func getUserEventStatusContainer() -> UserEventStatusContainer {
        return mUserEventStatusContainer
    }
    
    func getGroupId() -> Int64 {
        return (self.mBaseGroup?.groupId)!
    }
    
    func getGroupIdStr() -> String {
        return String(describing: self.mBaseGroup?.groupId)
    }
    
    func getEventTypeObj() -> EventType {
        return self.mBaseEventType
    }
    
    func getLocationCoordinatesString() -> String? {
        return self.mLocationCoordinates?.toString()
    }
    
    func getLocationCoordinatesPoints() -> Points? {
        return self.mLocationCoordinates
    }
    
    func setLocationName(_ locationName: String) {
        self.mLocationName = locationName;
    }

    func getEventProfilePicBase64Str() -> String? {
        return self.mEventProfilePicBase64Str
    }
    
    func setEventProfilePicBase64Str(_ str: String) {
        self.mEventProfilePicBase64Str = str;
    }

    func getEventProfilePicUrl() -> String? {
        return self.mEventProfilePicUrl
    }
    
    func setEventProfilePicUrl(_ str: String) {
        self.mEventProfilePicUrl = str;
    }

    
    func setLocationCoordinates(_ latitude: Double, longitude: Double) {
        self.mLocationCoordinates = Points(lat: latitude, long: longitude)
    }
    
    func setHasExpired(_ expired: Bool) {
        self.mHasExpired = expired
    }
    
    func setEventId(_ id: Int64) {
        self.mEventId = id
    }

    
    func getHasExpired() -> Bool {
        return self.mHasExpired
    }
    
    func getEventName() -> String {
        return self.mEventName
    }
    
    func getEventTypeStr() -> String {
        return String(describing: self.mEventType)
    }
    
    func getEventType() -> EventType {
        return self.mEventType
    }
    
    func getEventTypeId() -> Int {
        return self.mEventTypeId
    }
    
    func setStartTime(_ time: Int64) {
        self.mStartTime = time
    }
    
    func setEventName(_ eventName: String) {
        self.mEventName = eventName
    }
    
    func setEndTime(_ time: Int64) {
        self.mEndTime = time
    }
    
    func setEventType(_ type: EventType) {
        self.mEventType = type
    }
    
    func setEventTypeId(_ typeId: Int) {
        self.mEventTypeId = typeId
    }
    
    func setDecideByTime(_ time: Int64) {
        self.mDecideByTime = time
    }
    
    func setEventCreationTime(_ time: Int64) {
        self.mEventCreationTime = time
    }
    
    func setEventLastModifiedTime(_ time: Int64) {
        self.mEventLastModifiedTime = time
    }
    
    func setDecidedTime(_ time: Int64) {
        self.mDecidedTime = time
    }
    
    func setDecided(_ decidedFlag: Bool) {
        self.mDecided = decidedFlag
    }
    
//    func getMemberNames() -> [String]{
//        return mBaseGroup.getMembers()
//    }
    
//    public String[] getDateTime(long epoch) {
//    // epoch is in seconds, Date requires milliseconds
//    Date date = new Date(epoch * 1000);
//    DateFormat format = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss aa");
//    format.setTimeZone(TimeZone.getTimeZone("PST"));
//    String[] dateTimeArray = new String[2];
//    dateTimeArray[0] = format.format(date).split(" ")[0];
//    dateTimeArray[1] = format.format(date).split(" ")[1];
//    return dateTimeArray;
//    }
    
    func getEventId() -> Int64{
        return self.mEventId
    }
    
    func getEventIdStr() -> String {
        return String(self.mEventId);
    }
    
    func getStartTime() -> Int64 {
        return self.mStartTime;
    }
    
    func getDecided() -> Bool {
        return self.mDecided
    }
    
    func getEndTime() -> Int64 {
        return self.mEndTime
    }
    
    func getDecideByTime() -> Int64{
        return self.mDecideByTime
    }
    
    func getLocationName() -> String? {
        return self.mLocationName
    }
    
    func getEventCreationTime() -> Int64{
        return self.mEventCreationTime
    }
    
    func getDecidedTime() -> Int64{
        return self.mDecidedTime
    }
    
    func getEventLastModifiedTime() -> Int64 {
        return self.mEventLastModifiedTime
    }
    
    func setDecidedTime() -> Int64 {
        return self.mDecidedTime
    }
    
    func setFinished(_ finished: Bool) {
        self.mFinished = finished
    }
    
    func getFinished() -> Bool {
        return self.mFinished
    }
    
    func checkIfExpired() -> Bool {
        // TODO - need to merge both conditions
        if((self.getDecidedTime() - Utils.currentTimeMillis()) < 0 ) {
            return true
        }else if ((self.getDecidedTime() - Utils.currentTimeMillis()) == 0) {
            return true
        }
        return false
    }
    
    func setViewWithTimeLeft(futureEpochTimeInMilliSecs: Int64, label: UILabel) {
        let resultDate = Utils.convertDateToMeaningfulText(epochTimeinMilliSecs: futureEpochTimeInMilliSecs, future: true)
        if (resultDate == "EXPIRED") {
            label.textColor = UIColor(hex: Colors.md_red_400)
            self.setHasExpired(true)
        }
        if (!resultDate.contains("Days left")) {
            label.textColor = UIColor(hex: Colors.md_gray_600)
        }
        label.text  = resultDate
    }
    
    
    func getEventDataAsMap() -> [String: Any] {
        var eventMap =  [String: Any]()
        if (self.getEventId() != BaseEvent.UNDEFINED) {
            eventMap["eventId"] = self.getEventIdStr()
        }
        eventMap["parentEventId"] =  self.getParentEventIdStr()
        eventMap["parentEventType"] = self.getParentEventTypeStr()
        eventMap["createdByUserId"] = DcidrApplication.getInstance().getUser().getUserIdStr()
        eventMap["eventType"] = self.getEventTypeStr()
        eventMap["eventLastModifiedTime"] = self.getEventLastModifiedTime()
        eventMap["eventName"] = self.getEventName()
        eventMap["eventNotes"] = self.getEventNotes()
        eventMap["locationName"] = self.getLocationName()
        eventMap["locationCoordinates"] = self.getLocationCoordinatesString()
        eventMap["startTime"] = self.getStartTime()
        eventMap["endTime"] = self.getEndTime()
        eventMap["decideByTime"] = self.getDecideByTime()
        eventMap["eventProfilePicBase64Str"] = self.getEventProfilePicBase64Str()
        eventMap["eventCreationTime"] = self.getEventCreationTime()
        eventMap["eventAttributeMask"] = self.mEventAttributeMask!.getMask()
        return eventMap;
    }
    
    func populateMe(_ jsonObj : JSON) {
//        if let eventType: String = jsonObj["eventType"].stringValue {
//            self.setEventType((BaseEvent.EventType.enumFromString(eventType))!)
//        }
        if jsonObj["eventTypeId"].exists() {
            self.setEventTypeId(jsonObj["eventTypeId"].intValue)
            self.setEventType(EventType(rawValue: self.getEventTypeId())!)
        }
        if jsonObj["eventName"].exists() {
            self.setEventName(jsonObj["eventName"].stringValue)
        }
        if jsonObj["eventNotes"].exists() {
            self.setEventNotes(jsonObj["eventNotes"].stringValue)
        }
        if jsonObj["eventId"].exists() {
            self.setEventId(jsonObj["eventId"].int64Value)
        }
        if jsonObj["locationName"].exists() {
            self.setLocationName(jsonObj["locationName"].stringValue)
        }
        
        if jsonObj["locationCoordinates"].exists() {
            //var json = JSON(jsonObj["locationCoordinates"].stringValue)
            //print(json["x"].doubleValue)
            self.setLocationCoordinates(jsonObj["locationCoordinates"]["x"].doubleValue, longitude: jsonObj["locationCoordinates"]["y"].doubleValue)
            // or 
            //double[] points = Points.stringToDoubleArray(jsonObject.getString("locationCoordinates"));
            //self.setLocationCoordinates(points[0], points[1]);

            
        }
        if jsonObj["startTime"].exists() {
            self.setStartTime(jsonObj["startTime"].int64Value )
        }
        
        if jsonObj["endTime"].exists() {
            self.setEndTime(jsonObj["endTime"].int64Value )
        }
        if jsonObj["decideByTime"].exists() {
            self.setDecideByTime(jsonObj["decideByTime"].int64Value)
        }
        if jsonObj["eventCreationTime"].exists() {
            self.setEventCreationTime(jsonObj["eventCreationTime"].int64Value)
        }
        if jsonObj["eventLastModifiedTime"].exists() {
            self.setEventLastModifiedTime(jsonObj["eventLastModifiedTime"].int64Value)
        }
        if jsonObj["decidedTime"].exists() {
            self.setDecidedTime(jsonObj["decidedTime"].int64Value)
        }
        if jsonObj["decided"].exists() {
            self.setDecided(jsonObj["decided"].boolValue)
        }
        if jsonObj["finished"].exists() {
            self.setFinished(jsonObj["finished"].boolValue )
        }
        if jsonObj["eventAttributeMask"].exists() {
            self.getEventAttributeMask().setMask(mask: jsonObj["eventAttributeMask"].int32Value )
        }
        if jsonObj["childEventsData"].exists() {
            self.mChildEventsContainer.setBaseGroup(self.mBaseGroup!)
            self.mChildEventsContainer.populateEvents(JSON(jsonObj["childEventsData"].array!))
            for childEvent in self.mChildEventsContainer.getEventList(EventContainer.TypeOfResult.ALL) {
                childEvent.setParentEventId(getEventId());
                childEvent.setParentEventType(getEventType());
            }
        }
        if jsonObj["createdByFirstName"].exists() {
            self.setCreatedByName(jsonObj["createdByFirstName"].stringValue)
        }
        
        if jsonObj["createdByName"].exists() {
            self.setCreatedByName(jsonObj["createdByName"].stringValue)
        }

        if jsonObj["eventProfilePicUrl"].exists() {
            self.setEventProfilePicUrl(jsonObj["eventProfilePicUrl"].stringValue)
            self.loadAsyncUrl(self.getEventProfilePicUrl()!)
        }
        
    }
    
    
    func loadAsyncUrl(_ url: String){
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            let groupAsyncHttpClient: GroupAsyncHttpClient = GroupAsyncHttpClient()
            groupAsyncHttpClient.getGroupMediaByUrl( DcidrApplication.getInstance().getUser().getUserIdStr(), url: url, respHandler: {
                (statusCode, resp) in
                if (statusCode == 200) {
                    let json = JSON(resp.value!)
                    self.mEventProfilePicBase64Str = json["result"].stringValue
                    if (json["result"].stringValue != "null") {
                        self.mEventProfilePicData = NSData(base64Encoded: json["result"].stringValue, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) as? Data
                        self.mEventProfilePicFetchDoneCb(self.mEventProfilePicData!)
                    }
                }else {
                    print("error loading event profile pic")
                }
                
            })
            
        })
    }

    
    func releaseMemory() {
        
    }
}

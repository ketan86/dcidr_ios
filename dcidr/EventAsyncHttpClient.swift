//
//  EventHttpClient.swift
//  dcidr
//
//  Created by John Smith on 12/30/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import Alamofire
class EventAsyncHttpClient: BaseAsyncHttpClient {
    override init(){
        super.init()
    }
    
    func createEvent(userIdStr: String, groupIdStr: String, baseEvent: BaseEvent, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_GROUP_EVENTS_POST_URL = DcidrConstant.USER_GROUP_EVENTS_POST_URL
        USER_GROUP_EVENTS_POST_URL =  (USER_GROUP_EVENTS_POST_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_GROUP_EVENTS_POST_URL =  (USER_GROUP_EVENTS_POST_URL as NSString).replacingOccurrences(of: ":groupId", with: groupIdStr)
        let groupDict = baseEvent.getEventDataAsMap()
        self.post(USER_GROUP_EVENTS_POST_URL, params: groupDict, respCb: respHandler)
    }

    func getEventImagesUrls(userIdStr: String, groupIdStr: String, parentEventIdStr: String,
                            offset: Int, limit: Int, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var EVENT_MEDIA_IMAGE_GET_URL = DcidrConstant.EVENT_MEDIA_IMAGE_GET_URL
        EVENT_MEDIA_IMAGE_GET_URL =  (EVENT_MEDIA_IMAGE_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        EVENT_MEDIA_IMAGE_GET_URL =  (EVENT_MEDIA_IMAGE_GET_URL as NSString).replacingOccurrences(of: ":groupId", with: groupIdStr)
        EVENT_MEDIA_IMAGE_GET_URL =  (EVENT_MEDIA_IMAGE_GET_URL as NSString).replacingOccurrences(of: ":eventId", with: parentEventIdStr)
        
        EVENT_MEDIA_IMAGE_GET_URL = EVENT_MEDIA_IMAGE_GET_URL + "?offset=" + String(offset) + "&limit=" + String(limit) + "&fields=url"
        self.get(EVENT_MEDIA_IMAGE_GET_URL, respCb: respHandler)
    }
    
    
    func getEventImage(userIdStr: String, groupIdStr: String, parentEventIdStr: String, imageUrl: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var EVENT_MEDIA_IMAGE_GET_URL = DcidrConstant.EVENT_MEDIA_IMAGE_GET_URL
        EVENT_MEDIA_IMAGE_GET_URL =  (EVENT_MEDIA_IMAGE_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        EVENT_MEDIA_IMAGE_GET_URL =  (EVENT_MEDIA_IMAGE_GET_URL as NSString).replacingOccurrences(of: ":groupId", with: groupIdStr)
        EVENT_MEDIA_IMAGE_GET_URL =  (EVENT_MEDIA_IMAGE_GET_URL as NSString).replacingOccurrences(of: ":eventId", with: parentEventIdStr)
        EVENT_MEDIA_IMAGE_GET_URL = EVENT_MEDIA_IMAGE_GET_URL + "?fields=image";
        EVENT_MEDIA_IMAGE_GET_URL = EVENT_MEDIA_IMAGE_GET_URL + "&imageUrl=" + imageUrl
        self.get(EVENT_MEDIA_IMAGE_GET_URL, respCb: respHandler)
    }
    
    func setEventImage(userIdStr: String, groupIdStr: String, parentEventIdStr: String, eventImageName: String, base64Str: String,  respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var EVENT_MEDIA_IMAGE_POST_URL = DcidrConstant.EVENT_MEDIA_IMAGE_POST_URL
        EVENT_MEDIA_IMAGE_POST_URL =  (EVENT_MEDIA_IMAGE_POST_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        EVENT_MEDIA_IMAGE_POST_URL =  (EVENT_MEDIA_IMAGE_POST_URL as NSString).replacingOccurrences(of: ":groupId", with: groupIdStr)
        EVENT_MEDIA_IMAGE_POST_URL =  (EVENT_MEDIA_IMAGE_POST_URL as NSString).replacingOccurrences(of: ":eventId", with: parentEventIdStr)
        
        let params: [String:String] = [
            "eventPicBase64Str" : base64Str,
            "eventImageName" : eventImageName
        ]
        self.post(EVENT_MEDIA_IMAGE_POST_URL, params: params, respCb: respHandler)
    }
    
    func getEventTypes(_ userIdStr: String, offset: Int, limit: Int, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_EVENT_TYPES_GET_URL = DcidrConstant.USER_EVENT_TYPES_GET_URL
        USER_EVENT_TYPES_GET_URL =  (USER_EVENT_TYPES_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_EVENT_TYPES_GET_URL = USER_EVENT_TYPES_GET_URL + "?offset=" + String(offset) + "&limit=" + String(limit);
        self.get(USER_EVENT_TYPES_GET_URL, respCb: respHandler)
    }
    
    func getEvents(_ userIdStr : String, groupIdStr: String , offset: Int, limit : Int, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_GROUP_EVENTS_GET_URL = DcidrConstant.USER_GROUP_EVENTS_GET_URL
        USER_GROUP_EVENTS_GET_URL =  (USER_GROUP_EVENTS_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_GROUP_EVENTS_GET_URL =  (USER_GROUP_EVENTS_GET_URL as NSString).replacingOccurrences(of: ":groupId", with: groupIdStr)
        USER_GROUP_EVENTS_GET_URL = USER_GROUP_EVENTS_GET_URL + "?offset=" + String(offset) + "&limit=" + String(limit);
        self.get(USER_GROUP_EVENTS_GET_URL, respCb: respHandler)

    }
    func getEvent(_ userIdStr : String, groupIdStr: String , eventIdStr: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_GROUP_EVENT_GET_URL = DcidrConstant.USER_GROUP_EVENT_GET_URL
        USER_GROUP_EVENT_GET_URL =  (USER_GROUP_EVENT_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_GROUP_EVENT_GET_URL =  (USER_GROUP_EVENT_GET_URL as NSString).replacingOccurrences(of: ":groupId", with: groupIdStr)
        USER_GROUP_EVENT_GET_URL =  (USER_GROUP_EVENT_GET_URL as NSString).replacingOccurrences(of: ":eventId", with: eventIdStr)
        self.get(USER_GROUP_EVENT_GET_URL, respCb: respHandler)
        
    }
    
    
    func getEventsByQueryText(_ userIdStr : String, groupIdStr: String, queryText: String, offset: Int, limit : Int, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_GROUP_EVENTS_GET_URL = DcidrConstant.USER_GROUP_EVENTS_GET_URL
        USER_GROUP_EVENTS_GET_URL =  (USER_GROUP_EVENTS_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_GROUP_EVENTS_GET_URL =  (USER_GROUP_EVENTS_GET_URL as NSString).replacingOccurrences(of: ":groupId", with: groupIdStr)
        USER_GROUP_EVENTS_GET_URL = USER_GROUP_EVENTS_GET_URL + "?offset=" + String(offset) + "&limit=" + String(limit) + "&has=" + queryText;
        self.get(USER_GROUP_EVENTS_GET_URL, respCb: respHandler)
        
    }
    
    func getUserEventStatus(_ userIdStr: String, groupIdStr: String, eventIdStr: String, eventTypeStr: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_EVENT_STATUS_GET_URL = DcidrConstant.USER_EVENT_STATUS_GET_URL
        USER_EVENT_STATUS_GET_URL =  (USER_EVENT_STATUS_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_EVENT_STATUS_GET_URL =  (USER_EVENT_STATUS_GET_URL as NSString).replacingOccurrences(of: ":groupId", with: groupIdStr)
        USER_EVENT_STATUS_GET_URL =  (USER_EVENT_STATUS_GET_URL as NSString).replacingOccurrences(of: ":eventId", with: eventIdStr)
        USER_EVENT_STATUS_GET_URL = USER_EVENT_STATUS_GET_URL + "?eventType=" + eventTypeStr
        self.get(USER_EVENT_STATUS_GET_URL, respCb: respHandler)
    }

    
    
    func getChweet(_ userIdStr: String, groupIdStr: String, parentEventIdStr: String, offset: Int, limit : Int, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_EVENT_CHWEET_GET_URL = DcidrConstant.USER_EVENT_CHWEET_GET_URL
        
        USER_EVENT_CHWEET_GET_URL =  (USER_EVENT_CHWEET_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_EVENT_CHWEET_GET_URL =  (USER_EVENT_CHWEET_GET_URL as NSString).replacingOccurrences(of: ":groupId", with: groupIdStr)
        USER_EVENT_CHWEET_GET_URL =  (USER_EVENT_CHWEET_GET_URL as NSString).replacingOccurrences(of: ":parentEventId", with: parentEventIdStr)
        USER_EVENT_CHWEET_GET_URL = USER_EVENT_CHWEET_GET_URL + "?offset=" + String(offset) + "&limit=" + String(limit)
        self.get(USER_EVENT_CHWEET_GET_URL, respCb: respHandler)
    }
    
    func buzzUser(_ userIdStr: String, groupIdStr: String, eventIdStr: String, parentEventIdStr: String, buzzUserIdStr: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_EVENT_BUZZ_URL = DcidrConstant.USER_EVENT_BUZZ_URL
        USER_EVENT_BUZZ_URL =  (USER_EVENT_BUZZ_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_EVENT_BUZZ_URL =  (USER_EVENT_BUZZ_URL as NSString).replacingOccurrences(of: ":groupId", with: groupIdStr)
        USER_EVENT_BUZZ_URL =  (USER_EVENT_BUZZ_URL as NSString).replacingOccurrences(of: ":eventId", with: eventIdStr)
        let params: [String:String] = [
            "userId" : buzzUserIdStr,
            "parentEventId" : parentEventIdStr
        ]
        self.post(USER_EVENT_BUZZ_URL, params: params, respCb: respHandler)

    }

    
    func submitChweet(_ userIdStr: String, groupIdStr: String, parentEventIdStr: String,
                      chatMsg: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_EVENT_CHWEET_POST_URL = DcidrConstant.USER_EVENT_CHWEET_POST_URL
        USER_EVENT_CHWEET_POST_URL =  (USER_EVENT_CHWEET_POST_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_EVENT_CHWEET_POST_URL =  (USER_EVENT_CHWEET_POST_URL as NSString).replacingOccurrences(of: ":groupId", with: groupIdStr)
        USER_EVENT_CHWEET_POST_URL =  (USER_EVENT_CHWEET_POST_URL as NSString).replacingOccurrences(of: ":parentEventId", with: parentEventIdStr)
    
        let params: [String:String] = [
            "chweetText" : chatMsg
        ]
        self.post(USER_EVENT_CHWEET_POST_URL, params: params, respCb: respHandler)
    
    }
    
    
    func updateUserEventStatus(_ parentEventIdStr: String, parentEventTypeStr: String , userEventStatus: UserEventStatus, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_EVENT_STATUS_PUT_URL = DcidrConstant.USER_EVENT_STATUS_PUT_URL
        USER_EVENT_STATUS_PUT_URL =  (USER_EVENT_STATUS_PUT_URL as NSString).replacingOccurrences(of: ":userId", with: userEventStatus.getUserIdStr())
        USER_EVENT_STATUS_PUT_URL =  (USER_EVENT_STATUS_PUT_URL as NSString).replacingOccurrences(of: ":groupId", with: userEventStatus.getGroupIdStr())
        USER_EVENT_STATUS_PUT_URL =  (USER_EVENT_STATUS_PUT_URL as NSString).replacingOccurrences(of: ":eventId", with: userEventStatus.getEventIdStr())
        
        USER_EVENT_STATUS_PUT_URL = USER_EVENT_STATUS_PUT_URL + "?eventType=" + userEventStatus.getEventTypeStr()
        USER_EVENT_STATUS_PUT_URL = USER_EVENT_STATUS_PUT_URL + "&parentEventType=" + parentEventTypeStr;
        var params: [String:String] = userEventStatus.getUserEventDictRemote()
        params["parentEventId"] =  parentEventIdStr
        self.put(USER_EVENT_STATUS_PUT_URL, params: params, respCb: respHandler)
    }

    
}

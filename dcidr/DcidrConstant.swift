//
//  DcidrConstant.swift
//  dcidr
//
//  Created by John Smith on 12/27/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

class DcidrConstant {
    static let APP_PACKAGE_PATH = "dcidr."
    
    // dcidr server url
    static let DCIDR_SERVER_URL = "http://192.168.226.100"
    //static let DCIDR_SERVER_URL = "https://192.168.226.100:4443" //for server_kjoshi.js
    
    //static let DCIDR_SERVER_URL = "http://192.168.155.102"
    //static let DCIDR_SERVER_URL = "https://192.168.155.102" //for server_kjoshi.js
    
    static let BASE_URL = "/dcidr/v1"
    
    // yelp api keys
    static let YELP_CONSUMER_KEY = ""
    static let YELP_CONSUMER_SECRET = ""
    static let YELP_TOKEN = ""
    static let YELP_TOKEN_SECRET = ""
    
    // users api urls
    static let USERS_SIGNUP_POST_URL = "/users/signup";
    static let USER_GET_URL = "/users/:userId";
    static let USER_PUT_URL = "/users/:userId";
    static let USERS_LOGIN_POST_URL = "/users/login";

    
    // user device api urls
    static let USER_DEVICES_POST_URL = "/users/:userId/devices"
    static let USER_DEVICES_PUT_URL = "/users/:userId/devices"
    // group api urls
    static let USER_GROUPS_POST_URL = "/users/:userId/groups"
    static let USER_GROUPS_GET_URL = "/users/:userId/groups"
    static let USER_GROUP_GET_URL = "/users/:userId/groups/:groupId"
    static let USER_GROUP_PUT_URL = "/users/:userId/groups/:groupId"
    static let USER_GROUP_GET_MEMBERS_URL = "/users/:userId/groups/:groupId/members"
    
    // event api urls
    static let USER_EVENT_TYPE_GET_URL = "/users/:userId/eventTypes"
    static let USER_GROUP_UNREAD_EVENTS_GET_URL = "/users/:userId/groups/:groupId/unreadEvents"
    static let USER_GROUP_UNREAD_EVENTS_POST_URL = "/users/:userId/groups/:groupId/unreadEvents"
    static let USER_GROUP_EVENTS_POST_URL = "/users/:userId/groups/:groupId/events"
    static let USER_GROUP_EVENTS_GET_URL = "/users/:userId/groups/:groupId/events"
    static let USER_GROUP_EVENT_GET_URL = "/users/:userId/groups/:groupId/events/:eventId"
    static let USER_GROUP_EVENT_PUT_URL = "/users/:userId/groups/:groupId/events/:eventId"
    static let USER_EVENT_STATUS_GET_URL = "/users/:userId/groups/:groupId/events/:eventId/userEventStatus"
    static let USER_EVENT_STATUS_PUT_URL = "/users/:userId/groups/:groupId/events/:eventId/userEventStatus"
    static let USER_EVENT_TYPES_GET_URL = "/users/:userId/eventTypes"
    
    // Chweet api urls
    static let USER_EVENT_CHWEET_POST_URL = "/users/:userId/groups/:groupId/events/:parentEventId/submitChweet"
    static let USER_EVENT_CHWEET_GET_URL = "/users/:userId/groups/:groupId/events/:parentEventId/getChweet"
    
    
    // Buzz api urls
    static let USER_EVENT_BUZZ_URL = "/users/:userId/groups/:groupId/events/:eventId/buzz"
    
    // history api urls
    static let USER_HISTORY_GET_URL = "/users/:userId/history"
    
    // friend api urls
    static let USER_FRIENDS_POST_URL = "/users/:userId/friends"
    static let USER_FRIENDS_GET_URL = "/users/:userId/friends"
    static let USER_FRIEND_GET_URL = "/users/:userId/friends/:emailId"
    static let USER_FRIEND_POST_URL = "/users/:userId/friends/:emailId"
    
    //static let USER_CONTACTS_GET_URL = "/users/:userId/contacts"
    //static let USER_CONTACTS_POST_URL = "/users/:userId/contacts/:emailId"
    
    
    // media api url
    static let GROUPS_MEDIA_IMAGE_POST_URL = "/media/upload/users/:userId/groups/:groupId/image";
    static let GROUPS_MEDIA_IMAGE_GET_URL = "/media/download/users/:userId/groups/:groupId/image";
    static let EVENT_MEDIA_IMAGE_POST_URL = "/media/upload/users/:userId/groups/:groupId/events/:eventId/image";
    static let EVENT_MEDIA_IMAGE_GET_URL = "/media/download/users/:userId/groups/:groupId/events/:eventId/image";
    static let GROUPS_MEDIA_GET_BY_URL = "/media/download/users/:userId/url";
    static let USER_MEDIA_IMAGE_POST_URL = "/media/upload/users/:userId/image";
    static let USER_MEDIA_GET_BY_URL = "/media/download/users/:userId/url";

}

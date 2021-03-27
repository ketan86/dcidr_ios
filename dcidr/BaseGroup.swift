//
//  BaseGroup.swift
//  dcidr
//
//  Created by John Smith on 12/28/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON

class BaseGroup : Comparable {

    enum GroupSortKey {
        case GROUP_LAST_MODIFIED_TIME, GROUP_NAME
    }
    
    fileprivate var mGroupName : String  = ""
    fileprivate var mMembers :[String] = [String]()
    fileprivate var mMemberCount : Int = 0
    fileprivate var mGroupId : Int64 = -1
    fileprivate var mUnreadEventCount: Int = 0
    fileprivate var mTotalEventCount: Int = 0
    fileprivate var mGroupLastModifiedTime :Int64 = 0
    fileprivate var mGroupCreationTime: Int64 = 0
    fileprivate var mIsSelected : Bool = false
    fileprivate var mGroupProfilePicBase64Str : String = ""
    fileprivate var mGroupProfilePicUrl: String = ""
    fileprivate var mGroupProfilePicData: Data? = nil
    fileprivate var mEventContainer: EventContainer!
    fileprivate var mGroupProfilePicFetchDoneCb: (_ imageData: Data) -> () = {
        (imageData : Data) in
    }
    
    fileprivate var mGroupSortKey: GroupSortKey = GroupSortKey.GROUP_LAST_MODIFIED_TIME
    
    // comparable protocol implementation
    static func < (lhs: BaseGroup, rhs: BaseGroup) -> Bool {
        if(lhs.getGroupSortKey() == GroupSortKey.GROUP_NAME) {
            return lhs.mGroupName < rhs.mGroupName
        }else {
            return lhs.mGroupLastModifiedTime < rhs.mGroupLastModifiedTime
        }
    }
    
    static func <= (lhs: BaseGroup, rhs: BaseGroup) -> Bool {
        if(lhs.getGroupSortKey() == GroupSortKey.GROUP_NAME) {
            return lhs.mGroupName <= rhs.mGroupName
        }else {
            return lhs.mGroupLastModifiedTime <= rhs.mGroupLastModifiedTime
        }
    }
    static func > (lhs: BaseGroup, rhs: BaseGroup) -> Bool {
        if(lhs.getGroupSortKey() == GroupSortKey.GROUP_NAME) {
            return lhs.mGroupName > rhs.mGroupName
        }else {
            return lhs.mGroupLastModifiedTime > rhs.mGroupLastModifiedTime
        }
    }
    static func >= (lhs: BaseGroup, rhs: BaseGroup) -> Bool {
        if(lhs.getGroupSortKey() == GroupSortKey.GROUP_NAME) {
            return lhs.mGroupName >= rhs.mGroupName
        }else {
            return lhs.mGroupLastModifiedTime >= rhs.mGroupLastModifiedTime
        }
    }
    static func == (lhs: BaseGroup, rhs: BaseGroup) -> Bool {
        if(lhs.getGroupSortKey() == GroupSortKey.GROUP_NAME) {
            return lhs.mGroupName == rhs.mGroupName
        }else {
            return lhs.mGroupLastModifiedTime == rhs.mGroupLastModifiedTime
        }
    }
    // end comparable protocol implementation
    
    init () {
        self.mEventContainer = EventContainer()
        // set baseGroup to event Container
        self.mEventContainer.setBaseGroup(self)
    }
    
    func getIsSelected() -> Bool {
        return self.mIsSelected
    }
    
    func setIsSelected(_ flag: Bool) {
        self.mIsSelected = flag
    }
    
    func getMemberCount() -> Int {
        return self.mMemberCount
    }
    func getEventContainer() -> EventContainer {
        return self.mEventContainer
    }
    func setEventContainer(_ eventContainer: EventContainer){
        self.mEventContainer = eventContainer
    }
    
    func setGroupProfilePicFetchDoneCb( _ cb: @escaping (_ imageData:Data) -> ()) {
        self.mGroupProfilePicFetchDoneCb = cb
    }
    
    func setGroupSortKey(_ key: GroupSortKey){
        self.mGroupSortKey = key
    }
    
    func getGroupSortKey() -> GroupSortKey {
        return self.mGroupSortKey
    }
    var groupName: String {
        set(newValue) {self.mGroupName = newValue}
        get {
            return self.mGroupName
        }
    }
    

    var members: [String] {
        set(newValue) {
            self.mMembers = newValue
        }
        get {
            return self.mMembers
        }
    }
    
    var groupId: Int64 {
        set(newValue) {self.mGroupId = newValue}
        get {return self.mGroupId}
    }
    
    var unreadEventCount: Int {
        set(newValue) {self.mUnreadEventCount = newValue}
        get {return self.mUnreadEventCount}
    }
    var totalEventCount: Int {
        set(newValue) {self.mTotalEventCount = newValue}
        get {return self.mTotalEventCount}
    }
    
    var groupLastModifiedTime: Int64 {
        set(newValue) {self.mGroupLastModifiedTime = newValue}
        get {
            return self.mGroupLastModifiedTime
        }
    }
    var groupCreationTime: Int64 {
        set(newValue) {self.mGroupCreationTime = newValue}
        get {return self.mGroupCreationTime}
    }

    var groupProfilePicBase64Str: String {
        set(newValue) {self.mGroupProfilePicBase64Str = newValue}
        get {return self.mGroupProfilePicBase64Str}
    }

    var groupProfilePicUrl: String {
        set(newValue) {self.mGroupProfilePicUrl = newValue}
        get {return self.mGroupProfilePicUrl}
    }
   
    var groupProfilePicData: Data? {
        set(newValue) {self.mGroupProfilePicData = newValue}
        get {return self.mGroupProfilePicData}
    }

    func incrementTotalEventCount(){
        self.mTotalEventCount += 1
    }
    func getGroupMapForLocal() -> [String:String]{
        var groupMap =  [String: String]()
        groupMap["groupName"] = self.mGroupName
        groupMap["groupLastModifiedTime"] = String(self.mGroupLastModifiedTime)
        groupMap["groupProfilePicBase64Str"] = self.mGroupProfilePicBase64Str
        return groupMap
    }
    
    func getGroupMapForRemote() -> [String:Any]{
        var groupMap =  [String: Any]()
        groupMap["groupName"] = self.mGroupName
        groupMap["groupLastModifiedTime"] = String(self.mGroupLastModifiedTime)
        groupMap["groupProfilePicBase64Str"] = self.mGroupProfilePicBase64Str
        return groupMap
    }
    
    func populateMe(_ jsonObj: JSON) {
        if jsonObj["groupId"].exists() {
            self.mGroupId = jsonObj["groupId"].int64Value
        }
        if jsonObj["unreadEvents"].exists() {
            self.mUnreadEventCount = jsonObj["unreadEvents"].intValue
        }
        if jsonObj["totalEventCount"].exists() {
            self.mTotalEventCount = jsonObj["totalEventCount"].intValue
        }
        if jsonObj["groupName"].exists() {
            self.mGroupName = jsonObj["groupName"].stringValue
        }
        if jsonObj["groupLastModifiedTime"].exists() {
            self.mGroupLastModifiedTime = jsonObj["groupLastModifiedTime"].int64Value
        }
        if jsonObj["groupCreationTime"].exists() {
            self.mGroupCreationTime = jsonObj["groupCreationTime"].int64Value
        }
        if jsonObj["memberCount"].exists() {
            self.mMemberCount = jsonObj["memberCount"].intValue
        }
        if jsonObj["groupProfilePicBase64Str"].exists() {
            self.mGroupProfilePicBase64Str = jsonObj["groupProfilePicBase64Str"].stringValue
        }
        if jsonObj["groupProfilePicUrl"].exists() {
            self.mGroupProfilePicUrl = jsonObj["groupProfilePicUrl"].stringValue
            loadAsyncUrl(self.mGroupProfilePicUrl)
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
                    self.groupProfilePicBase64Str = json["result"].stringValue
                    self.groupProfilePicData = NSData(base64Encoded: json["result"].stringValue, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) as? Data
                    self.mGroupProfilePicFetchDoneCb(self.groupProfilePicData!)
                }else {
                    print("error loading group profile pic")
                }
                
                
            })
            
        })
    }
    
    
}

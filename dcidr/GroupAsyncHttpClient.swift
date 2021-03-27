//
//  GroupHttpClient.swift
//  dcidr
//
//  Created by John Smith on 12/28/16.
//  Copyright © 2016 dcidr. All rights reserved.
//
import Alamofire
class GroupAsyncHttpClient: BaseAsyncHttpClient {
    override init(){
        super.init()
    }
    
    func getGroups(_ userIdStr: String, offset: Int, limit: Int, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_GROUPS_GET_URL:String = DcidrConstant.USER_GROUPS_GET_URL
        USER_GROUPS_GET_URL =  (USER_GROUPS_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_GROUPS_GET_URL = USER_GROUPS_GET_URL + "?offset=" + String(offset) + "&limit=" + String(limit)
        self.get(USER_GROUPS_GET_URL, respCb: respHandler)
    }
    
    
    func getGroup(_ userIdStr: String, groupIdStr: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_GROUP_GET_URL:String = DcidrConstant.USER_GROUP_GET_URL
        USER_GROUP_GET_URL =  (USER_GROUP_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_GROUP_GET_URL = (USER_GROUP_GET_URL as NSString).replacingOccurrences(of: ":groupId", with: groupIdStr)
        self.get(USER_GROUP_GET_URL, respCb: respHandler)
    }
    
    func createGroup(userIdStr: String, baseGroup: BaseGroup, userContainer: UserContainer,
                     groupContainer: GroupContainer, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_GROUPS_POST_URL = DcidrConstant.USER_GROUPS_POST_URL
        USER_GROUPS_POST_URL =  (USER_GROUPS_POST_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        var baseGroupMap = baseGroup.getGroupMapForRemote()
        baseGroupMap["userIds"] = userContainer.getUserIds()
        baseGroupMap["groupIds"] = groupContainer.getGroupIds()
        self.post(USER_GROUPS_POST_URL, params: baseGroupMap, respCb: respHandler)

    }
    
    func getGroupsByQueryText(_ userIdStr: String, queryText: String, offset: Int, limit: Int, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_GROUPS_GET_URL:String = DcidrConstant.USER_GROUPS_GET_URL
        USER_GROUPS_GET_URL =  (USER_GROUPS_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_GROUPS_GET_URL = USER_GROUPS_GET_URL + "?offset=" + String(offset) + "&limit=" + String(limit) + "&has=" + queryText
        self.get(USER_GROUPS_GET_URL, respCb: respHandler)
    }
    
    func getGroupMediaByUrl(_ userIdStr: String, url:String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var GROUPS_MEDIA_GET_BY_URL: String = DcidrConstant.GROUPS_MEDIA_GET_BY_URL
        GROUPS_MEDIA_GET_BY_URL =  (GROUPS_MEDIA_GET_BY_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        GROUPS_MEDIA_GET_BY_URL = GROUPS_MEDIA_GET_BY_URL + "?url=" + url;
        self.get(GROUPS_MEDIA_GET_BY_URL, respCb: respHandler);
    }
    

    func getGroupMembers(userIdStr : String, groupIdStr : String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_GROUP_GET_MEMBERS_URL = DcidrConstant.USER_GROUP_GET_MEMBERS_URL
        USER_GROUP_GET_MEMBERS_URL =  (USER_GROUP_GET_MEMBERS_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_GROUP_GET_MEMBERS_URL =  (USER_GROUP_GET_MEMBERS_URL as NSString).replacingOccurrences(of: ":groupId", with: groupIdStr)
        //TODO: Kanishka
        // we need to convert this API into an offset + limit based API just like other APIs. Currently keeping it without offset
        self.get(USER_GROUP_GET_MEMBERS_URL, respCb: respHandler);
    }

}

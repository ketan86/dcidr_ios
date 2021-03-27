//
//  UserHttpClient.swift
//  dcidr
//
//  Created by John Smith on 12/27/16.
//  Copyright © 2016 dcidr. All rights reserved.
//
import Alamofire
class UserAsyncHttpClient: BaseAsyncHttpClient {
    override init(){
        super.init()
    }
    
    func loginUser(_ emailId: String, passwordDigest: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        let params: [String:String] = [
            "emailId" : emailId,
            "passwordDigest" : passwordDigest
        ]
        self.post(DcidrConstant.USERS_LOGIN_POST_URL, params: params, respCb: respHandler)
    }
    
    func createUser(emailIdStr: String, user : User,
                    responseHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->())  {
        var userDict = user.getUserMap() //
        userDict["emailId"] = emailIdStr
        post(DcidrConstant.USERS_SIGNUP_POST_URL + "?action=create", params: userDict, respCb: responseHandler)
    }
    
//    func singupUser(_ emailId: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
//        let params: [String:String] = [
//            "emailId" : emailId,
//        ]
//        var USERS_SIGNUP_POST_URL = DcidrConstant.USERS_SIGNUP_POST_URL
//        USERS_SIGNUP_POST_URL = USERS_SIGNUP_POST_URL + "?action=create"
//        post(USERS_SIGNUP_POST_URL, params: params, respCb: respHandler)
//    }	
    
    
    func verifyUser(_ emailId: String, confCode: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        let params: [String:String] = [
            "emailId" : emailId,
            "confirmationCode" : confCode,

        ]
        var USERS_SIGNUP_POST_URL = DcidrConstant.USERS_SIGNUP_POST_URL
        USERS_SIGNUP_POST_URL = USERS_SIGNUP_POST_URL + "?action=verify"
        self.post(USERS_SIGNUP_POST_URL, params: params, respCb: respHandler)
    }
    
    func createUser(_ user: User, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        let params: [String:String] = user.getUserMap()
        var USERS_SIGNUP_POST_URL = DcidrConstant.USERS_SIGNUP_POST_URL
        USERS_SIGNUP_POST_URL = USERS_SIGNUP_POST_URL + "?action=signup"
        self.post(USERS_SIGNUP_POST_URL, params: params, respCb: respHandler)
    }
    
    func getUser(_ userIdStr: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_GET_URL = DcidrConstant.USER_GET_URL
        USER_GET_URL =  (USER_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        self.get(USER_GET_URL, respCb: respHandler);

    }
    
    func getFriends(_ userIdStr: String, status: String, inviteBy: String, offset: Int, limit: Int, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_FRIENDS_GET_URL = DcidrConstant.USER_FRIENDS_GET_URL
        USER_FRIENDS_GET_URL =  (USER_FRIENDS_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        if(inviteBy == "true") {
            USER_FRIENDS_GET_URL = USER_FRIENDS_GET_URL + "?direct=true" + "&offset=" + String(offset) + "&limit=" + String(limit) + "&status=" + status + "&invitedBy=" + inviteBy
        }else {
            USER_FRIENDS_GET_URL = USER_FRIENDS_GET_URL + "?direct=true" + "&offset=" + String(offset) + "&limit=" + String(limit) + "&status=" + status
        }
        self.get(USER_FRIENDS_GET_URL, respCb: respHandler);
    }
    
    func getActiveFriendsByQueryText(_ userIdStr: String, queryText: String, offset: Int, limit: Int, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_FRIENDS_GET_URL = DcidrConstant.USER_FRIENDS_GET_URL
        USER_FRIENDS_GET_URL =  (USER_FRIENDS_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_FRIENDS_GET_URL = USER_FRIENDS_GET_URL + "?direct=true" + "&offset=" + String(offset) + "&limit=" + String(limit) + "&has=" + queryText + "&status=FRIEND"
        self.get(USER_FRIENDS_GET_URL, respCb: respHandler)
        
    }
    
    func inviteContact(_ userIdStr: String, friendEmailId: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_FRIEND_POST_URL = DcidrConstant.USER_FRIEND_POST_URL
        USER_FRIEND_POST_URL =  (USER_FRIEND_POST_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_FRIEND_POST_URL =  (USER_FRIEND_POST_URL as NSString).replacingOccurrences(of: ":emailId", with: friendEmailId)
        USER_FRIEND_POST_URL = USER_FRIEND_POST_URL + "?action=invite";
        self.post(USER_FRIEND_POST_URL, params: [:], respCb: respHandler)
    }
    
    func acceptInvitation(userIdStr: String, userEmailId: String, friendIdStr: String, friendEmailId: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_FRIEND_POST_URL = DcidrConstant.USER_FRIEND_POST_URL
        USER_FRIEND_POST_URL =  (USER_FRIEND_POST_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_FRIEND_POST_URL =  (USER_FRIEND_POST_URL as NSString).replacingOccurrences(of: ":emailId", with: friendEmailId)
        USER_FRIEND_POST_URL = USER_FRIEND_POST_URL + "?action=accept"
        let params: [String:String] = [
            "friendId" : friendIdStr,
            "userEmailId" : userEmailId,
            
            ]
        self.post(USER_FRIEND_POST_URL, params: params, respCb: respHandler)

    }
    func setUserMedia(userIdStr : String,  base64Str: String,  mediaType: String,  respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_MEDIA_IMAGE_POST_URL : String = DcidrConstant.USER_MEDIA_IMAGE_POST_URL
        if(mediaType == "image"){
            USER_MEDIA_IMAGE_POST_URL = (USER_MEDIA_IMAGE_POST_URL as NSString).replacingOccurrences(of:":userId", with: userIdStr)
        } // TODO for other media type
        let params: [String : String] =  [
            "imageBase64Str": base64Str
        ]
        self.post(USER_MEDIA_IMAGE_POST_URL, params: params, respCb: respHandler);
    }
    
    func declineInvitation(userIdStr: String, userEmailId: String, friendIdStr: String, friendEmailId: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_FRIEND_POST_URL = DcidrConstant.USER_FRIEND_POST_URL
        USER_FRIEND_POST_URL =  (USER_FRIEND_POST_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        
        USER_FRIEND_POST_URL =  (USER_FRIEND_POST_URL as NSString).replacingOccurrences(of: ":emailId", with: friendEmailId)
        USER_FRIEND_POST_URL = USER_FRIEND_POST_URL + "?action=decline"
        let params: [String:String] = [
            "friendId" : friendIdStr,
            "userEmailId" : userEmailId,
        
        ]
        self.post(USER_FRIEND_POST_URL, params: params, respCb: respHandler)

    }
    

    func getDirectAndIndirectContacts(_ userIdStr: String, offset : Int, limit: Int, queryText : String?, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_FRIENDS_GET_URL = DcidrConstant.USER_FRIENDS_GET_URL
        USER_FRIENDS_GET_URL =  (USER_FRIENDS_GET_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        if (queryText == nil) {
            USER_FRIENDS_GET_URL = USER_FRIENDS_GET_URL + "?directAndIndirect=true" + "&offset=" + String(offset) + "&limit=" + String(limit)
        } else {
            USER_FRIENDS_GET_URL = USER_FRIENDS_GET_URL + "?directAndIndirect=true" + "&offset=" + String(offset) + "&limit=" + String(limit) + "&has=" + queryText!
        }
        self.get(USER_FRIENDS_GET_URL, respCb: respHandler);
    }
    
    
    func getUserMediaByUrl(_ userIdStr: String, url: String, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_MEDIA_GET_BY_URL = DcidrConstant.USER_MEDIA_GET_BY_URL
        USER_MEDIA_GET_BY_URL =  (USER_MEDIA_GET_BY_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        USER_MEDIA_GET_BY_URL = USER_MEDIA_GET_BY_URL + "?url=" + url;
        self.get(USER_MEDIA_GET_BY_URL, respCb: respHandler);
    }

    
    func createUserDevice(userIdStr: String,  userMap: Dictionary<String, String>, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_DEVICES_POST_URL = DcidrConstant.USER_DEVICES_POST_URL
        USER_DEVICES_POST_URL =  (USER_DEVICES_POST_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        let params: [String:String] = userMap
        self.post(USER_DEVICES_POST_URL, params: params, respCb: respHandler)
    }
    
    func updateUserDevice(userIdStr: String,  userMap: Dictionary<String, String>, respHandler: @escaping (_ statusCode: Int?, _ resp: Result<Any>)->()) {
        var USER_DEVICES_PUT_URL = DcidrConstant.USER_DEVICES_PUT_URL
        USER_DEVICES_PUT_URL =  (USER_DEVICES_PUT_URL as NSString).replacingOccurrences(of: ":userId", with: userIdStr)
        let params: [String:String] = userMap
        self.put(USER_DEVICES_PUT_URL, params: params, respCb: respHandler)
    }
}

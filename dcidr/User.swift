//
//  User.swift
//  dcidr
//
//  Created by John Smith on 12/26/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import SwiftyJSON

class User {
    
    enum LoginType: Int {
        case FACEBOOK = 1, GOOGLE, DCIDR
        
        static func enumFromString(_ str:String) -> LoginType? {
            var i = 1
            while let item = LoginType(rawValue: i) {
                print(item)
                if String(describing: item) == str {
                    return item
                }
                i += 1
            }
            return nil
        }
        
        static func getValue(_ value: Int) -> LoginType? {
            return LoginType(rawValue: value)
        }
    }
    
    enum UserSortKey {
        case USER_FIRST_NAME, USER_LAST_NAME, USER_EMAIL_ID
    }
    
    fileprivate var mUserId: Int64 = -1
    fileprivate var mLoginType: LoginType = LoginType.DCIDR
    fileprivate var mFirstName: String = ""
    fileprivate var mLastName : String  = ""
    fileprivate var mUserCreationTime: Int64 = 0
    fileprivate var mLoginTime: Int64 = 0
    fileprivate var mLogoutTime : Int64 = 0
    fileprivate var mEmailId : String = ""
    fileprivate var mIsPopulated : Bool = false
    fileprivate var mUserProfilePicUrl : String = ""
    fileprivate var mAuthToken : String = ""
    fileprivate var mUserProfilePicBase64Str : String = ""
    fileprivate var mPasswordDigest : String = ""
    fileprivate var mUserProfilePicData: Data? = nil
    fileprivate var mIsSelected: Bool = false
    fileprivate var mUserSortKey: UserSortKey = UserSortKey.USER_FIRST_NAME
    fileprivate var mUserProfilePicFetchDoneCb: (_ imageData: Data?) -> () = {
        (imageData : Data?) in
    }
    
    init () {
    }
    
    
    func getIsSelected() -> Bool {
        return self.mIsSelected
    }
    
    func setIsSelected(_ flag: Bool) {
        self.mIsSelected = flag
    }
    
    func setUserProfilePicFetchDoneCb( _ cb: @escaping (_ imageData:Data?) -> ()) {
        self.mUserProfilePicFetchDoneCb = cb
    }

    
    func setUserSortKey(userSortKey: UserSortKey) {
        self.mUserSortKey = userSortKey
    }
    
    func getUserSortKey() -> UserSortKey {
        return self.mUserSortKey
        
    }
    
    func getUserSortKeyStr() -> String {
        return String(describing: self.mUserSortKey)
    }
    
    func getUserId() -> Int64 {
        return self.mUserId
    }
    
    func getUserIdStr() -> String {
        return String(self.mUserId)
    }
    
    var userId: String {
        set(newValue) {
            self.mUserId = Int64(newValue)!
        }
        
        get {
            return String(self.mUserId)
        }
        
    }
    
    var isSelected: Bool {
        set(newValue) {
            self.mIsSelected = newValue
        }
        
        get {
            return self.mIsSelected
        }
        
    }

    var loginType: LoginType {
        set(newValue) {
            self.mLoginType = newValue
        }
        
        get {
            return self.mLoginType
        }
        
    }
    var firstName: String {
        set(newValue) {
            self.mFirstName = newValue
        }
        
        get {
            return self.mFirstName
        }
        
    }
    var lastName: String{
        set(newValue) {
            self.mLastName = newValue
        }
        
        get {
            return self.mLastName
        }
        
    }
    var userCreationTime: Int64{
        set(newValue) {
            self.mUserCreationTime = newValue
        }
        
        get {
            return self.mUserCreationTime
        }
        
    }
    var loginTime: Int64{
        set(newValue) {
            self.mLoginTime = newValue
        }
        
        get {
            return self.mLoginTime
        }
        
    }
    var logoutTime: Int64 {
        set(newValue) {
            self.mLogoutTime = newValue
        }
        
        get {
            return self.mLogoutTime
        }
        
    }
    var emailId: String {
        set(newValue) {
            self.mEmailId = newValue
        }
        
        get {
            return self.mEmailId
        }
        
    }
    var isPopulated: Bool {
        set(newValue) {
            self.mIsPopulated = newValue
        }
        
        get {
            return self.mIsPopulated
        }
        
    }
    var passwordDigest: String{
        set(newValue) {
            self.mPasswordDigest = newValue
        }
        
        get {
            return self.mPasswordDigest
        }
        
    }
    
    var userProfilePicBase64Str: String{
        set(newValue) {
            self.mUserProfilePicBase64Str = newValue
        }
        
        get {
            return self.mUserProfilePicBase64Str
        }
        
    }
    
    
    var userProfilePicUrl: String{
        set(newValue) {
            self.mUserProfilePicUrl = newValue
        }
        
        get {
            return self.mUserProfilePicUrl
        }
        
    }
    
    var authToken: String {
        set(newValue) {
            self.mAuthToken = newValue
        }
        
        get {
            return self.mAuthToken
        }
        
    }
    
    func getUserName() -> String {
        return self.mFirstName + " " + self.mLastName
    }
    
    
    func getUserProfilePicData() -> Data? {
        return self.mUserProfilePicData
    }

    func getUserMap() -> Dictionary<String, String> {
        var userMap =  [String: String]()
        userMap["emailId"] = self.mEmailId
        userMap["firstName"] = self.mFirstName
        userMap["lastName"] = self.mLastName
        userMap["loginType"] = String(describing: self.mLoginType)
        userMap["logoutTime"] = String(self.mLogoutTime)
        userMap["passwordDigest"] = self.mPasswordDigest
        return userMap
    }
    

    func populateMe(_ jsonObj: JSON) {
        if jsonObj["userId"].exists() {
            self.mUserId = jsonObj["userId"].int64Value
        }
       
        if jsonObj["emailId"].exists() {
            self.mEmailId = jsonObj["emailId"].stringValue
        }
        if jsonObj["firstName"].exists() {
            self.mFirstName = jsonObj["firstName"].stringValue
        }
        if jsonObj["lastName"].exists() {
            self.mLastName = jsonObj["lastName"].stringValue
        }
        if jsonObj["loginType"].exists() {
            self.mLoginType = LoginType.getValue(jsonObj["loginType"].intValue)!
        }
        if jsonObj["loginTime"].exists() {
            self.mLoginTime = jsonObj["loginTime"].int64Value
        }
        if jsonObj["logoutTime"].exists() {
            self.mLogoutTime =  jsonObj["logoutTime"].int64Value
        }
        if jsonObj["userCreationTime"].exists() {
            self.mUserCreationTime = jsonObj["userCreationTime"].int64Value
        }
        if jsonObj["authToken"].exists() {
            self.mAuthToken = jsonObj["authToken"].stringValue
        }
        if jsonObj["userProfilePicUrl"].exists() {
            self.mUserProfilePicUrl = jsonObj["userProfilePicUrl"].stringValue
            self.loadAsyncUrl(self.mUserProfilePicUrl)
        }
        
        // set isPopulated to true
        self.mIsPopulated = true
    }
    
    
    func loadAsyncUrl(_ url: String){
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            let userAsyncHttpClient  = UserAsyncHttpClient()
            userAsyncHttpClient.getUserMediaByUrl(DcidrApplication.getInstance().getUser().getUserIdStr(), url: url, respHandler: {
                (statusCode, resp) in
                if (statusCode == 200) {
                    let json = JSON(resp.value!)
                    self.userProfilePicBase64Str = json["result"].stringValue
                    if(self.userProfilePicBase64Str == "null") {
                        self.mUserProfilePicFetchDoneCb(nil)
                        return
                    }
                    self.mUserProfilePicData = NSData(base64Encoded: json["result"].stringValue, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) as? Data
                    self.mUserProfilePicFetchDoneCb(self.mUserProfilePicData!)
                }else {
                    print("error loading user profile pic")
                }
                
                
            })
            
        })
    }    
}

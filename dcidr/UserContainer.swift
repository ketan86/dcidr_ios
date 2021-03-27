//
//  UserContainer.swift
//  dcidr
//
//  Created by John Smith on 12/28/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class UserContainer {
    fileprivate var mUserDict: Dictionary<Int64, User>!
    
    init(){
        self.mUserDict = Dictionary<Int64, User>()
    }
    
    func populateUser(_ jsonUserArray: JSON) {
        if let jsonUsers = jsonUserArray.array {
            for jsonUser in jsonUsers {
                if(self.mUserDict[jsonUser["userId"].int64Value] != nil){
                    self.mUserDict[jsonUser["userId"].int64Value]?.populateMe(jsonUser)
                    continue
                }
                let user: User = User()
                user.populateMe(jsonUser)
                self.mUserDict[jsonUser["userId"].int64Value] = user
            }
        }
    }
    
    func getUserIds() -> Array<Int64> {
        return Array(self.mUserDict.keys)
    }
    func removeUser(_ user: User) {
        self.mUserDict.removeValue(forKey: user.getUserId())
    }
    
    func addUser(_ user: User) {
        self.mUserDict[user.getUserId()] = user
    }
    
    func clearUserMap(){
        self.mUserDict.removeAll()
    }

    func getUserMap() -> Dictionary<Int64, User>{
        return self.mUserDict
    }
    
    func getUserList() -> Array<User> {
        return Array(self.mUserDict.values)
    }
    
    func clear(){
        self.mUserDict.removeAll()
    }
}

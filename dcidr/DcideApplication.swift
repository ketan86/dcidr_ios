		//
//  DcideApplication.swift
//  dcidr
//
//  Created by John Smith on 12/27/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

class DcidrApplication {
    var mUser : User!
    var mUserCache : UserCache!
    var mGlobalGroupContainer: GroupContainer!
    var mGlobalHistoryContainer: HistoryContainer!
    var mGlobalContactContainer: ContactContainer!
    
    static let dcidrApplication : DcidrApplication = DcidrApplication()
    
    static func getInstance() -> DcidrApplication{
       return dcidrApplication
    }
    
    

    fileprivate init() {
        self.mUser = nil
        self.mUserCache = nil
        self.initInstances()
        // nothing right now
    }
    
    
    func getUser() -> User {
        if (self.mUser != nil) {
            return self.mUser!
        }else {
            self.mUser = User()
            return self.mUser
        }
    }
    
    func getUserCache() -> UserCache {
        if (self.mUserCache != nil) {
            return self.mUserCache!
        }else {
            self.mUserCache = UserCache()
            return self.mUserCache
        }
    }
    func getGlobalGroupContainer() -> GroupContainer {
        if (self.mGlobalGroupContainer != nil) {
            return self.mGlobalGroupContainer!
        }else {
            self.mGlobalGroupContainer = GroupContainer()
            return self.mGlobalGroupContainer
        }
    }

    func getGlobalHistoryContainer() -> HistoryContainer {
        if (self.mGlobalHistoryContainer != nil) {
            return self.mGlobalHistoryContainer!
        }else {
            self.mGlobalHistoryContainer = HistoryContainer()
            return self.mGlobalHistoryContainer
        }
    }
    
    func getGlobalContactContainer() -> ContactContainer {
        if (self.mGlobalContactContainer != nil) {
            return self.mGlobalContactContainer!
        }else {
            self.mGlobalContactContainer = ContactContainer()
            return self.mGlobalContactContainer
        }
    }

    
    func initInstances() {
        self.mUser = self.getUser()
        self.mUserCache = self.getUserCache()
        self.mGlobalGroupContainer = self.getGlobalGroupContainer()
        self.mGlobalHistoryContainer = self.getGlobalHistoryContainer()
        self.mGlobalContactContainer = self.getGlobalContactContainer()

    }
    
    func clear() {
        self.mUser = nil
        self.mUserCache = nil
        self.mGlobalGroupContainer = nil
        self.mGlobalHistoryContainer = nil
        self.mGlobalContactContainer = nil

    }
    
}

//
//  Chweet.swift
//  dcidr
//
//  Created by John Smith on 1/22/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class Chweet: Comparable {
    fileprivate var mChweetId: Int64!
    fileprivate var mUserId: Int64!
    fileprivate var mChweetText: String!
    fileprivate var mChweetTime: Int64!
    fileprivate var mUserName: String!
    fileprivate var mParentEventId: Int64!
    fileprivate var mParentEventTypeId: Int!
    fileprivate var mChweetColor: Int!
    
    init(){
        
    }
    
    static func > (lhs: Chweet, rhs: Chweet) -> Bool {
        return lhs.mChweetTime > rhs.mChweetTime
    }
    
    static func == (lhs: Chweet, rhs: Chweet) -> Bool {
        return lhs.mChweetTime == rhs.mChweetTime
    }
    static func < (lhs: Chweet, rhs: Chweet) -> Bool {
        return lhs.mChweetTime < rhs.mChweetTime
    }
    
    func getChweetId() -> Int64 {
        return self.mChweetId
    }
    func getChweetColor() -> Int {
        return self.mChweetColor
    }
    func getUserId() -> Int64{
        return self.mUserId
    }
    func getChweetText() -> String {
        return self.mChweetText
    }
    func  getChweetTime() -> Int64 {
        return  self.mChweetTime
    }
    func getChweetUserName() -> String{
        return  self.mUserName
    }
    func getChweetParentEventId() -> Int64 {
        return  self.mParentEventId
    }
    func  getChweetParentEventTypeId() -> Int {
        return  self.mParentEventTypeId
    }
    
    func setChweetId(_ chweetId: Int64) {
        self.mChweetId = chweetId
    }
    func setChweetColor(_ chweetColor: Int) {
        self.mChweetColor = chweetColor
    }
    func setUserId(_ userId: Int64) {
        self.mUserId = userId
    }
    
    func setChweetTime(_ chweetTime: Int64) {
        self.mChweetTime = chweetTime
    }
    func setChweetText(_ chweetText: String) {
        self.mChweetText = chweetText
    }
    func setChweetUserName(_ userName: String) {
        self.mUserName = userName
    }
    func setChweetParentEventId(_ parentEventId: Int64) {
        self.mParentEventId = parentEventId
    }
    func setChweetParentEventTypeId(_ parentEventTypeId: Int) {
        self.mParentEventTypeId = parentEventTypeId
    }
    
    
    func populateMe(_ jsonObj : JSON) {
        if jsonObj["chweetId"].exists() {
            self.setChweetId(jsonObj["chweetId"].int64Value)
        }
        if jsonObj["userId"].exists() {
            self.setUserId(jsonObj["userId"].int64Value)
        }
        if jsonObj["chweetText"].exists() {
            self.setChweetText(jsonObj["chweetText"].stringValue)
        }
        if jsonObj["chweetTime"].exists() {
            self.setChweetTime(jsonObj["chweetTime"].int64Value)
        }
        if jsonObj["parentEventId"].exists() {
            self.setChweetParentEventId(jsonObj["parentEventId"].int64Value)
        }
        if jsonObj["parentEventTypeId"].exists() {
            self.setChweetParentEventTypeId(jsonObj["parentEventTypeId"].intValue)
        }
        if jsonObj["firstName"].exists() {
            self.setChweetUserName(jsonObj["firstName"].stringValue + " " + jsonObj["lastName"].stringValue)
        }
    }
    func releaseMemory() {
        
    }
}

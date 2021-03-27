//
//  Contact.swift
//  dcidr
//
//  Created by John Smith on 1/29/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class Contact: User, Comparable {

    enum ContactType: Int {
        case FACEBOOK = 1
        case GOOGLE = 2
        case DCIDR = 3
        case PHONE = 4
        
        static func enumFromString(_ str:String) -> ContactType? {
            var i = 0
            while let item = ContactType(rawValue: i) {
                if String(describing: item) == str {
                    return item
                }
                i += 1
            }
            return nil
        }
    }
    
    enum StatusType: Int {
        case FRIEND = 1
        case NOT_FRIEND = 2
        case INVITED = 3
        
        static func enumFromString(_ str:String) -> StatusType? {
            var i = 0
            while let item = StatusType(rawValue: i) {
                if String(describing: item) == str {
                    return item
                }
                i += 1
            }
            return nil
        }
    }
    
    fileprivate var mStatusType : StatusType = StatusType.NOT_FRIEND
    fileprivate var mContactType: ContactType = ContactType.DCIDR
    
    init(_ contactType: ContactType) {
        super.init()
        self.mContactType = contactType
        //set the user sort key to be email
        self.setUserSortKey(userSortKey: UserSortKey.USER_EMAIL_ID);
    }
    
    
    // comparable protocol implementation
    static func < (lhs: Contact, rhs: Contact) -> Bool {
        if(lhs.getUserSortKey() == User.UserSortKey.USER_EMAIL_ID) {
            return lhs.emailId < rhs.emailId
        }else {
            return lhs.firstName < rhs.firstName
        }
    }
    
    static func > (lhs: Contact, rhs: Contact) -> Bool {
        if(lhs.getUserSortKey() == User.UserSortKey.USER_EMAIL_ID) {
            return lhs.emailId > rhs.emailId
        }else {
            return lhs.firstName > rhs.firstName
        }
    }
    
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        if(lhs.getUserSortKey() == User.UserSortKey.USER_EMAIL_ID) {
            return lhs.emailId == rhs.emailId
        }else {
            return lhs.firstName == rhs.firstName
        }
    }
    // end comparable protocol implementation
    
    

    func getStatusType() -> StatusType {
        return  self.mStatusType
    }
    
    
    func getStatusTypeStr() -> String {
        return String(describing: self.mStatusType)
    }
    
    func setStatusType(_ statusType: StatusType) {
        //        if (statusTypeStr.equals("NOT_FRIEND")) {
        //            this.mStatusType = StatusType.NOT_FRIEND;
        //        } else if (statusTypeStr.equals("FRIEND")){
        //            this.mStatusType = StatusType.FRIEND;
        //        } else if (statusTypeStr.equals("INVITED")) {
        //            this.mStatusType = StatusType.INVITED;
        //        }
        self.mStatusType = statusType
    }
    func setStatusTypeId(_ statusTypeInt: Int) {
        if (statusTypeInt == 1) {
            self.mStatusType = StatusType.FRIEND
        } else if (statusTypeInt == 2){
            self.mStatusType = StatusType.NOT_FRIEND
        } else if (statusTypeInt == 3) {
            self.mStatusType = StatusType.INVITED
        }
    }
    
    func getContactType() -> ContactType {
        return self.mContactType
    }
    
    func setContactType(_ contactType: ContactType){
        self.mContactType = contactType
    }
    
    override func populateMe(_ jsonObj: JSON) {
        super.populateMe(jsonObj)
        if jsonObj["statusTypeId"].exists() {
            self.setStatusTypeId(jsonObj["statusTypeId"].intValue)
        }
    }
}

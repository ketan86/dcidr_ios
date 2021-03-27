//
//  NotificationCodees.swift
//  dcidr
//
//  Created by John Smith on 3/5/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
class NotificationCodes {
    // group specific ntf codes
    static let GROUP_NTF_CODE_START = 1000;
    static let GROUP_CREATE_NTF_CODE = 1000;
    
    static let GROUP_NTF_CODE_END = 3999;
    
    // event specific ntf codes
    static let EVENT_NTF_CODE_START = 4000;
    static let EVENT_CREATE_NTF_CODE = 4000;
    static let EVENT_WILL_EXPIRE_NTF_CODE = 4100;
    static let EVENT_HAS_EXPIRED_NTF_CODE = 4101;
    static let EVENT_STATUS_NTF_CODE = 4200;
    static let EVENT_BUZZ_NTF_CODE = 4300;
    static let EVENT_NEW_CHWEET_NTF_CODE = 4400;
    static let EVENT_IMAGE_CREATE_NTF_CODE = 4500;
    static let EVENT_NTF_CODE_END = 4999;
    
    // friend specific ntf codes
    static let FRIEND_NTF_CODE_START = 6000;
    static let FRIEND_INVITE_NTF_CODE = 6000;
    static let FRIEND_REMIND_NTF_CODE = 6001;
    static let FRIEND_ACCEPT_NTF_CODE = 6002;
    static let FRIEND_DECLINE_NTF_CODE = 6003;
    static let FRIEND_NTF_CODE_END = 6999;
    
    
    //    // chweet specific nft codes
    //    static let CHWEET_EVENT_NTF_CODE_START = 7000;
    //        static let CHWEET_EVENT_NTF_CODE = 7000;
    //    static let CHWEET_EVENT_NTF_CODE_END = 7999;
}

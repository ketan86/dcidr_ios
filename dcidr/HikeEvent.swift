//
//  HikeEvent.swift
//  dcidr
//
//  Created by John Smith on 1/3/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
class HikeEvent : BaseEvent {
    
    fileprivate var mHikeEventType: HikeEventType!
    //private UserEventStatusContainer mUserEventStatusContainer;
    
    required init() {
        self.mHikeEventType = HikeEventType()
    }

    func getEventTypeObj() -> HikeEventType{
        return self.mHikeEventType
    }
}

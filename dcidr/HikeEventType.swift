//
//  HikeEventType.swift
//  dcidr
//
//  Created by John Smith on 12/30/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import Hex
class HikeEventType: BaseEventType {
    fileprivate var mEventTypeColor: UIColor!
    fileprivate var mEventTypeIcon : UIImage!
    required init(){
        super.init()
        self.mEventTypeColor = UIColor(hex: Colors.md_amber_200)
        self.mEventTypeIcon = UIImage(named: "mountain_icon")
    }
    
    override func getEventTypeColor() -> UIColor {
        return self.mEventTypeColor;
    }
    
    override func getEventTypeIcon() -> UIImage {
        return self.mEventTypeIcon;
    }
}

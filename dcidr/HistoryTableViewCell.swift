//
//  HistoryTableViewCell.swift
//  dcidr
//
//  Created by John Smith on 1/28/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import UIKit
import Foundation
import Agrume
class HistoryTableViewCell: UITableViewCell {
    
    fileprivate var mArrayList: Array<BaseEvent>!
    fileprivate var mBaseViewController: BaseViewController!
    fileprivate var mBaseEvent: BaseEvent!
    
    @IBOutlet weak var mEventName: UILabel!
    @IBOutlet weak var mEventProfilePic: UIImageView!
    @IBOutlet weak var mEventPlace: UILabel!
    @IBOutlet weak var mEventMembersCount: UILabel!
    
    func setCellData(_ baseViewController: BaseViewController, arrayList: Array<BaseEvent>){
        self.mBaseViewController = baseViewController
        self.mArrayList = arrayList
    }
    
    func getCellView(indexPath: IndexPath) -> HistoryTableViewCell {
        self.mBaseEvent = self.mArrayList[indexPath.row]
        self.mEventName.text = self.mBaseEvent.getEventName()
        self.mEventPlace.text = self.mBaseEvent.getLocationName()
        self.mEventMembersCount.text = String(self.mBaseEvent.getBaseGroup()!.getMemberCount()) + " Members"
        // set default image image due to reusability of the cell
        self.mEventProfilePic.image = UIImage(named: "user_default_icon")
        self.mEventProfilePic.layer.borderWidth = 0
        self.mEventProfilePic.layer.cornerRadius = self.mEventProfilePic.frame.height / 2
        self.mEventProfilePic.clipsToBounds = true
        self.mEventProfilePic.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
        if(self.mBaseEvent.getEventProfilePicData() == nil) {
            self.mBaseEvent.seEventProfilePicFetchDoneCb(
                { (imageData : Data) in
                self.mEventProfilePic.image = self.mBaseViewController.resizeImage(UIImage(data: imageData)!, newWidth : 500)
            })
        }else {
            self.mEventProfilePic.image = self.mBaseViewController.resizeImage(UIImage(data: self.mBaseEvent.getEventProfilePicData()!)!, newWidth : 500)
        }
        
        
        // set tap gesture on mEventProfilePic
        self.mEventProfilePic.isUserInteractionEnabled = true
        self.mEventProfilePic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HistoryTableViewCell.onHistoryProfilePicClicked)))
        
        return self
        
    }
    
    func onHistoryProfilePicClicked(imageView : UIImageView) {
        if let data = self.mBaseEvent.getEventProfilePicData() {
            let agrume = Agrume(image: UIImage(data: data)!, backgroundColor: .white)
            agrume.showFrom(self.mBaseViewController)
        }
        
    }
    
}

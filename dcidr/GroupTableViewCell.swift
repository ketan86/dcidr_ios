//
//  CustomGroupTableViewCell.swift
//  dcidr
//
//  Created by John Smith on 12/28/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import UIKit
import Foundation
import Agrume
class GroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mGroupNameLabel: UILabel!

    @IBOutlet weak var mEventCountLabel: UILabel!
    @IBOutlet weak var mGroupLastModifiedTimeLabel: UILabel!
    
    @IBOutlet weak var mGroupProfilePicImageView: UIImageView!
    fileprivate var mArrayList: Array<BaseGroup>!
    fileprivate var mBaseViewController: BaseViewController!
    fileprivate var mImageData : Data? = nil
    fileprivate var mBaseGroup: BaseGroup!

    func setCellData(_ baseViewController: BaseViewController, arrayList: Array<BaseGroup>){
        self.mBaseViewController = baseViewController
        self.mArrayList = arrayList
    }
    
    func getCellView(indexPath: IndexPath) -> GroupTableViewCell {
        self.mBaseGroup = self.mArrayList[indexPath.row]
        self.mGroupNameLabel.text = self.mBaseGroup.groupName
        self.mEventCountLabel.text = String(self.mBaseGroup.totalEventCount) + " Activity"
        self.mGroupLastModifiedTimeLabel.text = Utils.convertDateToMeaningfulText(epochTimeinMilliSecs: self.mBaseGroup.groupLastModifiedTime, future: false)
        
        // set default image image due to reusability of the cell
        self.mGroupProfilePicImageView.image = UIImage(named: "user_default_icon")
        self.mGroupProfilePicImageView.layer.borderWidth = 0
        self.mGroupProfilePicImageView.layer.cornerRadius = self.mGroupProfilePicImageView.frame.height / 2
        self.mGroupProfilePicImageView.clipsToBounds = true
        self.mGroupProfilePicImageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
        if(self.mBaseGroup.groupProfilePicData == nil) {
            self.mBaseGroup.setGroupProfilePicFetchDoneCb({ (imageData : Data) in
                self.mGroupProfilePicImageView.image = self.mBaseViewController.resizeImage(UIImage(data: imageData)!, newWidth : 500)
                self.mImageData  = imageData
            })
        }else {
            self.mGroupProfilePicImageView.image = self.mBaseViewController.resizeImage(UIImage(data: self.mBaseGroup.groupProfilePicData!)!, newWidth : 500)
            self.mImageData  = self.mBaseGroup.groupProfilePicData
        }
        
        
        // set tap gesture on mGroupProfilePicImageView
        self.mGroupProfilePicImageView.isUserInteractionEnabled = true
        self.mGroupProfilePicImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GroupTableViewCell.onGroupProfilePicClicked)))
        
        return self

    }
    
    func onGroupProfilePicClicked(imageView : UIImageView) {
        if let data = self.mBaseGroup.groupProfilePicData {
            let agrume = Agrume(image: UIImage(data: data)!, backgroundColor: .white)
            agrume.showFrom(self.mBaseViewController)
        }

    }

}

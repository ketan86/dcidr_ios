//
//  ImageViewControllerCollectionViewCell.swift
//  dcidr
//
//  Created by John Smith on 2/20/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
class ImageViewControllerCollectionViewCell: UICollectionViewCell {
    
    fileprivate var mBaseViewController: BaseViewController!
    fileprivate var mArrayList: Array<Contact>!
    fileprivate let mUserIdStr: String = DcidrApplication.getInstance().getUser().getUserIdStr()
    
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mAddedByUserName: UILabel!
    
    func setCellData(_ baseViewController: BaseViewController, arrayList: Array<Contact>){
        self.mBaseViewController = baseViewController
        self.mArrayList = arrayList
    }
    
    func getCellView(indexPath: IndexPath) -> ImageViewControllerCollectionViewCell {
        return self
    }
}

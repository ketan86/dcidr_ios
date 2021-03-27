//
//  ChweetCollectionViewCell.swift
//  dcidr
//
//  Created by John Smith on 1/22/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
class ChweetCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mChweetMsg: UILabel!
    @IBOutlet weak var mChweetUserName: UILabel!
    fileprivate var mBaseViewController: BaseViewController!
    fileprivate var mArrayList: Array<Chweet>!
    
    func setCellData(_ baseViewController: BaseViewController, arrayList: Array<Chweet>){
        self.mBaseViewController = baseViewController
        self.mArrayList = arrayList
    }
    
    func getCellView(indexPath: IndexPath) -> ChweetCollectionViewCell {
    
        self.mChweetMsg.text = self.mArrayList[indexPath.row].getChweetText()
        self.mChweetUserName.text = self.mArrayList[indexPath.row].getChweetUserName()
        self.mChweetMsg.isUserInteractionEnabled = true
        self.mChweetMsg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChweetCollectionViewCell.onChweetCellClicked)))
        return self
    }
    
    func onChweetCellClicked(sender: UIGestureRecognizer) {
        self.mBaseViewController.showAlertMsgWithOptions("Chweet by " + self.mChweetUserName.text!, textMsg: self.mChweetMsg.text!, okCb: {_ in
            	// no-op
        }, cancelCb: {_ in
            // no-op
        })
    }
}

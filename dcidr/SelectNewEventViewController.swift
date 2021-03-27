//
//  SelectNewEventViewController.swift
//  dcidr
//
//  Created by John Smith on 12/29/16.
//  Copyright © 2016 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Hex
class SelectNewEventViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var mGroupId: Int64? = nil
    var mParentEventId: Int64? = nil
    var mParentEventType : String? = nil
    @IBOutlet weak var mSelectNewEventCollectionView: UICollectionView!
    var mEventTypeContainer: EventTypeContainer = EventTypeContainer()
    fileprivate var mEventAsyncHttpClient: EventAsyncHttpClient!
    fileprivate var mUserId: String = DcidrApplication.getInstance().getUser().userId

    
    override func handleInputDataDict(data: [String: Any]?) {
    }
    override func viewDidLoad() {
        self.showUIActivityIndicator()
        self.setUserFetchDoneCb({
            self.initViewController()
            self.stopUIActivityIndicator()
        })
        super.viewDidLoad()
    }
    
    override func initViewController() {
        self.mEventAsyncHttpClient = EventAsyncHttpClient()
        self.showUIActivityIndicator()
        self.mEventAsyncHttpClient.getEventTypes(self.mUserId, offset: 0, limit: 1000, respHandler: {
        (statusCode, resp) in
            self.stopUIActivityIndicator()
            if let statusCode: Int = statusCode {
                let json = JSON(resp.value!)
                if(statusCode ==  200) {
                    self.mEventTypeContainer.populateEventType(json["result"])
                    self.mSelectNewEventCollectionView.reloadData()
                }else {
                    self.showAlertMsg(json["error"].string!)
                }
            }else {
                self.showAlertMsg("error fetching event types")
            }

        
        })
        // tell collectionView to use current class for datasource and delegate
        self.mSelectNewEventCollectionView.delegate = self
        self.mSelectNewEventCollectionView.dataSource = self
    }
    

    @IBAction func onCancelButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CustomNewEventViewCell

        if(self.mGroupId == nil) {
            // launch main controller
            let createGroupViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
            createGroupViewCtr.mEventType = cell.newEventNameLabel.text
            self.present(createGroupViewCtr, animated: true, completion: nil)
        }else {
            let newBaseEventViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "NewBaseEventViewController") as! NewBaseEventViewController
            newBaseEventViewCtr.mEventType = cell.newEventNameLabel.text
            newBaseEventViewCtr.mGroupId = self.mGroupId
            newBaseEventViewCtr.mParentEventId = self.mParentEventId
            newBaseEventViewCtr.mParentEventType = self.mParentEventType
            self.present(newBaseEventViewCtr, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mEventTypeContainer.getEventTypeList().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomNewEventViewCell", for: indexPath) as! CustomNewEventViewCell
        let baseEventType = self.mEventTypeContainer.getEventTypeList()[indexPath.row]
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(hex: Colors.md_gray_400).cgColor
        cell.newEventNameLabel.text = baseEventType.getEventType()?.capitalized
        cell.newEventTypeImageView.image = baseEventType.getEventTypeIcon()
        return cell
    }
}


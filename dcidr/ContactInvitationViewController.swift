//
//  ContactInvitation.swift
//  dcidr
//
//  Created by John Smith on 1/29/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
class ContactInvitationViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    fileprivate var mInInvitationContactContainer: ContactContainer!
    fileprivate var mOutInvitationContactContainer: ContactContainer!
    fileprivate var mContactInInvitationVCH : ContactInvitationViewControllerHelper!
    fileprivate var mContactOutInvitationVCH : ContactInvitationViewControllerHelper!
    @IBOutlet weak var mInInvitationCollectionView: UICollectionView!
    @IBOutlet weak var mOutInvitationCollectionView: UICollectionView!
    
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
    
    @IBAction func onCancelButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onInviteContactButtonClicked(_ sender: UIBarButtonItem) {
        // launch  invite contact view controller
        let inviteContactViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "InviteContactViewController") as! InviteContactViewController
        self.present(inviteContactViewCtr, animated: true, completion: nil)

    }
    override func initViewController(){
        self.mInInvitationContactContainer = ContactContainer()
        self.mOutInvitationContactContainer = ContactContainer()
        
        // tell tableView to use current class for datasource and delegate
        self.mInInvitationCollectionView.delegate = self
        self.mInInvitationCollectionView.dataSource = self
        self.mOutInvitationCollectionView.delegate = self
        self.mOutInvitationCollectionView.dataSource = self
        
        self.mContactInInvitationVCH = ContactInvitationViewControllerHelper(self)
        self.mContactInInvitationVCH.setInvitationType(type: ContactInvitationViewControllerHelper.InvitationType.INCOMING)
        self.mContactInInvitationVCH.fetchContacts(0, visibleEndIndex: 5)
        
        self.mContactOutInvitationVCH = ContactInvitationViewControllerHelper(self)
        self.mContactOutInvitationVCH.setInvitationType(type: ContactInvitationViewControllerHelper.InvitationType.OUTGOING)
        self.mContactOutInvitationVCH.fetchContacts(0, visibleEndIndex: 5)
        
    }
    
    func getInInvitationContactContainer() -> ContactContainer{
        return self.mInInvitationContactContainer
    }

    func getOutInvitationContactContainer() -> ContactContainer{
        return self.mOutInvitationContactContainer
    }
    
    // chweet -> onNoOfRows
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (collectionView == self.mInInvitationCollectionView) {
            print("in")
            print(self.mInInvitationContactContainer.getContactList(typeOfResult: ContactContainer.TypeOfResult.ALL).count)
            print("in")
            return self.mInInvitationContactContainer.getContactList(typeOfResult: ContactContainer.TypeOfResult.ALL).count
        }else if (collectionView == self.mOutInvitationCollectionView) {
            print("out")
            print(self.mOutInvitationContactContainer.getContactList(typeOfResult: ContactContainer.TypeOfResult.ALL).count)
            print("out")
            return self.mOutInvitationContactContainer.getContactList(typeOfResult: ContactContainer.TypeOfResult.ALL).count
        }
        return 0
    }
    
    // chweet -> onView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == self.mInInvitationCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InInvitationCollectionViewCell", for: indexPath) as! InInvitationCollectionViewCell
            cell.setCellData(self, arrayList: self.mInInvitationContactContainer.getContactList(typeOfResult: ContactContainer.TypeOfResult.ALL))
            return cell.getCellView(indexPath: indexPath)
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OutInvitationCollectionViewCell", for: indexPath) as! OutInvitationCollectionViewCell
            cell.setCellData(self, arrayList: self.mOutInvitationContactContainer.getContactList(typeOfResult: ContactContainer.TypeOfResult.ALL))
            return cell.getCellView(indexPath: indexPath)
        }
    }
    
    func onFetchResponse(invitationType : ContactInvitationViewControllerHelper.InvitationType,statusCode: Int?, resp: Result<Any>){
        if let statusCode: Int = statusCode {
            let json = JSON(resp.value!)
            if(statusCode ==  200) {
                if(invitationType == ContactInvitationViewControllerHelper.InvitationType.INCOMING) {
                    self.mInInvitationContactContainer.populateMe(json["result"], contactType: Contact.ContactType.DCIDR)
                    self.mInInvitationContactContainer.refreshContactList(ContactContainer.TypeOfResult.ALL)
                    self.mInInvitationCollectionView.reloadData()
                }else if (invitationType == ContactInvitationViewControllerHelper.InvitationType.OUTGOING) {
                    self.mOutInvitationContactContainer.populateMe(json["result"], contactType: Contact.ContactType.DCIDR)
                    self.mOutInvitationContactContainer.refreshContactList(ContactContainer.TypeOfResult.ALL)
                    self.mOutInvitationCollectionView.reloadData()
                }
            }else {
                self.showAlertMsg(json["error"].string!)
            }
        }else {
            self.showAlertMsg("error fetching groups")
        }
    }
    

}

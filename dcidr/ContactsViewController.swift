//
//  ContactViewController.swift
//  dcidr
//
//  Created by John Smith on 1/28/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit
import Contacts
class ContactsViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    fileprivate var mPhoneContactsViewControllerHelper : PhoneContactsViewControllerHelper!
    fileprivate var mDcidrContactsViewControllerHelper : DcidrContactsViewControllerHelper!

    fileprivate var mGlobalContactContainer = DcidrApplication.getInstance().getGlobalContactContainer()
    fileprivate var mTempContactContainer: ContactContainer!
    fileprivate var mSearchString: String? = nil
    @IBOutlet weak var mSearchBar: UISearchBar!
    
    @IBOutlet weak var mContactTableView: UITableView!
    
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
        // disable contact selection
        self.mContactTableView.allowsSelection = false
        
        self.mPhoneContactsViewControllerHelper = PhoneContactsViewControllerHelper(self)
        self.mDcidrContactsViewControllerHelper = DcidrContactsViewControllerHelper(self)

        // tell tableView to use current class for datasource and delegate
        self.mContactTableView.delegate = self
        self.mContactTableView.dataSource = self
        // tell searchBar to use current class for delegate
        self.mSearchBar.delegate = self
        self.mTempContactContainer = ContactContainer()
        self.mPhoneContactsViewControllerHelper.loadPhoneContacts(doneCb: {
            (contacts: Array<CNContact>) -> () in
            for c in contacts {
                for email in c.emailAddresses {
                    let pc = Contact(Contact.ContactType.PHONE)
                    pc.emailId = email.value as String
                    pc.firstName = c.givenName
                    pc.lastName = c.familyName
                    if(self.mSearchString == nil) {
                        self.mGlobalContactContainer.addContact(contactEmailId: email.value as String, contact: pc, typeOfResult: ContactContainer.TypeOfResult.SCROLLED)
                    }else {
                        self.mGlobalContactContainer.addContact(contactEmailId: email.value as String, contact: pc, typeOfResult: ContactContainer.TypeOfResult.SEARCHED)
                    }
                }
            }
            self.mContactTableView.reloadData()
        })
    }
    
    @IBAction func mContactInvitationButtonClicked(_ sender: UIBarButtonItem) {
        // launch contact invitation view controller
        let contactInvitationViewCtr = self.storyboard?.instantiateViewController(withIdentifier: "ContactInvitationViewController") as! ContactInvitationViewController
        self.present(contactInvitationViewCtr, animated: true, completion: nil)
    }
    
    func getGlobalContactContainer() -> ContactContainer {
        return self.mGlobalContactContainer
    }
    
    func getTempContactContainer() -> ContactContainer {
        return self.mTempContactContainer
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.mTempContactContainer.clear()
        // clear all the searched results from the globalContactContainer
        self.mGlobalContactContainer.deleteContacts(ContactContainer.TypeOfResult.SEARCHED)
        // set end index to the size of the fetched Contact
        //self.mPhoneViewControllerHelper.getFetchHandler().getFetchManager().setEndIndex(self.mGlobalContactContainer.getGroupContainerEventList(ContactContainer.TypeOfResult.SCROLLED).count)
        
        // set searchString to nil and then reload the data
        self.mSearchString = nil
        self.mContactTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // implement search logic here
        self.mSearchString = searchText.lowercased()
        if(self.mSearchString != "") {
            
            // clear mTempContactContainer ContactList
            self.mTempContactContainer.clear()
            
            //clear fetchManager start and end index since each search will want a new initialization
            //self.mPhoneViewControllerHelper.getFetchHandler().getFetchManager().reset()
            // fetch Contacts for 0 with the search string
            //self.mPhoneViewControllerHelper.fetchContact(0, visibleEndIndex: 5, searchString: self.mSearchString!)
            
            self.mContactTableView.reloadData()
            
        }else {
            self.searchBarCancelButtonClicked(self.mSearchBar)
        }
        
    }
    
    
    // onNoOfRows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.mSearchString == nil) {
            return self.mGlobalContactContainer.getContactList(typeOfResult: ContactContainer.TypeOfResult.SCROLLED).count
        }else {
            return self.mTempContactContainer.getContactList(typeOfResult: ContactContainer.TypeOfResult.ALL).count
        }
    }
    
    // onView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        if(self.mSearchString == nil) {
            cell.setCellData(self, arrayList: self.mGlobalContactContainer.getContactList(typeOfResult: ContactContainer.TypeOfResult.SCROLLED))
        }else {
            cell.setCellData(self, arrayList: self.mTempContactContainer.getContactList(typeOfResult: ContactContainer.TypeOfResult.ALL))
        }
        return cell.getCellView(indexPath: indexPath)
    }
    
    // onScroll
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //self.mContactViewControllerHelper.fetchContact(indexPath.row - self.mContactTableView.visibleCells.count, visibleEndIndex: indexPath.row - 1, searchString: self.mSearchString)
    }
    
    func onFetchResponse(_ statusCode: Int?, resp: Result<Any>){
        if let statusCode: Int = statusCode {
            let json = JSON(resp.value!)
            if(statusCode ==  200) {
                if(self.mSearchString == nil) {
                    self.mGlobalContactContainer.populateMe(json["result"], contactType: Contact.ContactType.DCIDR)
                    self.mGlobalContactContainer.refreshContactList(ContactContainer.TypeOfResult.SCROLLED)
                }else {
                    self.mTempContactContainer.populateMe(json["result"], contactType: Contact.ContactType.DCIDR)
                    self.mGlobalContactContainer.populateContacts(self.mTempContactContainer.getContactList(typeOfResult: ContactContainer.TypeOfResult.ALL), isSearchedResult: true)
                    self.mTempContactContainer.refreshContactList(ContactContainer.TypeOfResult.ALL)
                }
                self.mContactTableView.reloadData()
            }else {
                self.showAlertMsg(json["error"].string!)
            }
        }else {
            self.showAlertMsg("error fetching groups")
        }
    }

    
    
}

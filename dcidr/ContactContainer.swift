//
//  ContactContainer.swift
//  dcidr
//
//  Created by John Smith on 1/29/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import SwiftyJSON
class ContactContainer {
    
    fileprivate var mContactWrapperDict: Dictionary<String, ContactWrapper>!
    fileprivate var mContactList: Array<Contact>!
    fileprivate var mContactSortKey: Contact.UserSortKey!
   
    init(){
        self.mContactWrapperDict = Dictionary<String, ContactWrapper>()
        self.mContactList = Array<Contact>()
        self.mContactSortKey = Contact.UserSortKey.USER_FIRST_NAME
    }
    
    enum TypeOfResult {
        case SEARCHED, SCROLLED, ALL
    }

    fileprivate class ContactWrapper {
        fileprivate var mIsSearchedResult : Bool = false
        fileprivate var  mContact: Contact!
        fileprivate var mContactType: Contact.ContactType!
        
        required init(_ contact: Contact){
            self.mContact = contact
        }
        func setIsSearchedResult(_ isSearchedResult: Bool){
            self.mIsSearchedResult = isSearchedResult
        }
        func getIsSearchedResult() -> Bool {
            return self.mIsSearchedResult
        }
        
        func getContact() -> Contact {
            return self.mContact
        }
    }
    
    func populateMe(_ jsonArray: JSON, contactType: Contact.ContactType) {
        if let jsonContacts = jsonArray.array {
            for jsonContact in jsonContacts {
                if(self.mContactWrapperDict[jsonContact["emailId"].stringValue] != nil) {
                    let c = self.mContactWrapperDict[jsonContact["emailId"].stringValue]!
                    c.getContact().populateMe(jsonContact)
                    c.getContact().setContactType(contactType)
                }else {
                    let c = Contact(contactType)
                    c.populateMe(jsonContact)
                    c.setContactType(Contact.ContactType.DCIDR);
                    let contactWrapper = ContactWrapper(c)
                    contactWrapper.setIsSearchedResult(false)
                    self.mContactWrapperDict[c.emailId] = contactWrapper
                }
            }
        }else {
            print("error parsing json")
        }
    }
    
    func deleteContacts(_ typeOfResult: TypeOfResult){
        for baseContactWrapper in self.mContactWrapperDict.values {
            if(typeOfResult == TypeOfResult.SEARCHED) {
                if (baseContactWrapper.getIsSearchedResult()) {
                    self.mContactWrapperDict.removeValue(forKey: baseContactWrapper.getContact().emailId)
                }
            }else if(typeOfResult == TypeOfResult.SCROLLED){
                if(!baseContactWrapper.getIsSearchedResult()){
                    self.mContactWrapperDict.removeValue(forKey: baseContactWrapper.getContact().emailId)
                }
            }else {
                self.mContactWrapperDict.removeValue(forKey: baseContactWrapper.getContact().emailId)
            }
        }
        
    }
    
    func refreshContactList(_ typeOfResult: TypeOfResult) {
        self.mContactList.removeAll()
        for contactWrapper in self.mContactWrapperDict.values {
            self.mContactList.append(contactWrapper.getContact())
        }
        self.mContactList.sort(by: >)
    }
    
    func setContactSortKey(contactSortKey: Contact.UserSortKey) {
        self.mContactSortKey = contactSortKey
    }
    
    func getContact(contactEmailId: String) -> Contact? {
        if let contactWrapper = self.mContactWrapperDict[contactEmailId] {
            return contactWrapper.getContact()
        }else {
            return nil
        }
    }
    
    
    func removeContact(contactEmailId: String) {
        self.mContactWrapperDict.removeValue(forKey: contactEmailId)
    }
    
    func addContact(contactEmailId: String, contact: Contact, typeOfResult: TypeOfResult) {
        let c = ContactWrapper(contact)
        if (typeOfResult == TypeOfResult.SEARCHED) {
            c.mIsSearchedResult = true
        }
        self.mContactWrapperDict[contactEmailId] = ContactWrapper(contact)
    }

    func populateContacts(_ arrayList: Array<Contact>, isSearchedResult: Bool){
        for contact in arrayList {
            if(isSearchedResult) {
                if(self.mContactWrapperDict[contact.emailId] == nil) {
                    let contactWrapper = ContactWrapper(contact)
                    contactWrapper.setIsSearchedResult(isSearchedResult)
                    self.mContactWrapperDict[contact.emailId] = contactWrapper
                }
            }else {
                let contactWrapper = ContactWrapper(contact)
                contactWrapper.setIsSearchedResult(isSearchedResult)
                self.mContactWrapperDict[contact.emailId] = contactWrapper
            }
        }
    }
    
    
    func getContactList(typeOfResult: TypeOfResult) -> Array<Contact> {
        self.refreshContactList(typeOfResult)
        return self.mContactList
    }
    

    func clear() {
        self.mContactList.removeAll()
        self.mContactWrapperDict.removeAll()
    }
    
    
    
    
    
    

    
    
    
}

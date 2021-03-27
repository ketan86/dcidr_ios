//
//  PhoneContactsViewControllerHelper.swift
//  dcidr
//
//  Created by John Smith on 1/28/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import Contacts
class PhoneContactsViewControllerHelper : BaseContactsViewControllerHelper {
    
    fileprivate var mContactStore: CNContactStore!
    override init(_ contactsViewController: ContactsViewController) {
        super.init(contactsViewController)
        self.mContactStore = CNContactStore()
    }
    
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        // Get authorization
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        // Find out what access level we have currently
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.mContatsViewController.showAlertMsg(message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    
    func loadPhoneContacts(doneCb: @escaping (Array<CNContact>) -> ()) {
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            self.requestForAccess { (accessGranted) -> Void in
                if accessGranted {
                    var contacts = Array<CNContact>()

                    let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                                CNContactEmailAddressesKey,
                                CNContactPhoneNumbersKey,
                                CNContactImageDataAvailableKey,
                                CNContactThumbnailImageDataKey,
                                CNContactImageDataKey] as [Any]
                    let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
                    
                    do {
                        try self.mContactStore.enumerateContacts(with: request) {
                            (contact, stop) in
                            // Array containing all unified contacts from everywhere
                            contacts.append(contact)
                        }
                        DispatchQueue.main.async {
                            doneCb(contacts)
                        }
                    }
                    catch {
                        print("unable to fetch contacts")
                    }
                }
            }
        })
    }
    
    
}

//
//  BaseContactsViewControllerHelper.swift
//  dcidr
//
//  Created by John Smith on 1/28/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
class BaseContactsViewControllerHelper  {
    let mContatsViewController : ContactsViewController
    let mUserId: String = DcidrApplication.getInstance().getUser().getUserIdStr()

    init(_ contactsViewController: ContactsViewController) {
        self.mContatsViewController = contactsViewController
    }
    
    
}

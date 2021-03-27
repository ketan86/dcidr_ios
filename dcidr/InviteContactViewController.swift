//
//  InviteContactViewController.swift
//  dcidr
//
//  Created by John Smith on 1/30/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class InviteContactViewController : BaseViewController {
    
    //fileprivate var mUserAsyncHttpClient: UserAsyncHttpClient!
    fileprivate let mUserIdStr: String = DcidrApplication.getInstance().getUser().getUserIdStr()
    @IBOutlet weak var mContactEmailTextField: UITextField!
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
   
    override func initViewController(){
        self.mUserAsyncHttpClient = UserAsyncHttpClient()
    }
    
    @IBAction func mContactInviteButton(_ sender: UIButton) {
        self.showAlertMsgWithOptions("Remind", textMsg: "Send invitation to " + self.mContactEmailTextField.text! + " ?", okCb: { (_) in
            // send invitation
            let userAsyncHttpClient = UserAsyncHttpClient()
            userAsyncHttpClient.inviteContact(self.mUserIdStr, friendEmailId: self.mContactEmailTextField.text!, respHandler: { (statusCode, resp) in
                if let statusCode: Int = statusCode {
                    let json = JSON(resp.value!)
                    if(statusCode ==  200) {
                        
                        self.showAlertMsg("contact invitation sent")
                        
                    }else {
                        self.showAlertMsg(json["error"].string!)
                    }
                }else {
                    self.showAlertMsg("error sending invitation")
                }
            })
        }) { (_) in
            // no-op
        }
    }
}

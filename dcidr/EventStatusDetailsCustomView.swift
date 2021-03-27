//
//  EventStatusDetailsCustomView.swift
//  dcidr
//
//  Created by John Smith on 1/24/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
class EventStatusDetailsCustomView : UIView {
    
    
    var view: UIView!
    var nibName: String  = "EventStatusDetailsCustomView"
    
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!

    @IBOutlet weak var userEventStatus: UILabel!
    
    @IBOutlet weak var userBuzzButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setup() {
        view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        view.layer.borderColor = UIColor(hex: Colors.md_gray_400).cgColor
        view.layer.borderWidth = 0.5
        addSubview(view)
        
    }

    func loadViewFromNib() -> UIView {
        let bundel = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.nibName, bundle: bundel)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}

//
//  SelectedGroupEventCustomView.swift
//  dcidr
//
//  Created by John Smith on 1/4/17.
//  Copyright © 2017 dcidr. All rights reserved.
//

import Foundation
import UIKit
class SelectedGroupEventCustomView: UIView {
    

    var view: UIView!
    var nibName: String  = "SelectedGroupEventCustomView"
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventCreatedBy: UILabel!
    @IBOutlet weak var eventLeaderColorStripe: UIView!
    
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

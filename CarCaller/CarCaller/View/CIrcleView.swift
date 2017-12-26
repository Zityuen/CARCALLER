//
//  CIrcleView.swift
//  CarCaller
//
//  Created by chityuen on 12/20/17.
//  Copyright © 2017 chityuen. All rights reserved.
//

import UIKit
@IBDesignable

class CIrcleView: UIView {

    @IBInspectable var borderColor: UIColor?{
        didSet{
            setupView()
        }
    }
    
    override func awakeFromNib() {
        setupView()
    }
    
    func setupView(){
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderWidth = 1.5
        self.layer.borderColor = borderColor?.cgColor
//        self.layer.borderColor = self.backgroundColor?.cgColor
    }
}

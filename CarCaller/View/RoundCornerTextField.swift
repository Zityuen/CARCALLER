//
//  RoundCornerTextField.swift
//  CarCaller
//
//  Created by chityuen on 12/22/17.
//  Copyright © 2017 chityuen. All rights reserved.
//

import UIKit

class RoundCornerTextField: UITextField {
    
    
    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = self.frame.height / 2
        print(self.frame)
    }
    
    
//    override func textRect(forBounds bounds: CGRect) -> CGRect {
//        let textOffset:CGFloat = self.frame.height / 2
////        return CGRect(x: 0 + textOffset, y: 0, width: self.frame.width - textOffset, height: self.frame.height)
//        return self.frame
//    }
//
//    override func editingRect(forBounds bounds: CGRect) -> CGRect {
//        let textOffset:CGFloat = self.frame.height / 2
//        return self.frame
//    }
}

//
//  InsetTextField.swift
//  Social Networking
//
//  Created by AADITYA NARVEKAR on 8/13/17.
//  Copyright © 2017 Aaditya Narvekar. All rights reserved.
//

import UIKit

@IBDesignable
class InsetTextField: UITextField {
    @IBInspectable var insetX: CGFloat = 0.0
    @IBInspectable var insetY: CGFloat = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.75
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }

}

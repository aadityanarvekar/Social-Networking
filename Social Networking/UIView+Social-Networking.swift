//
//  UIView+Social-Networking.swift
//  Social Networking
//
//  Created by AADITYA NARVEKAR on 8/12/17.
//  Copyright © 2017 Aaditya Narvekar. All rights reserved.
//

import Foundation
import UIKit

private var _roundedSquareView = false
private var _dropShadowView = false
private var _roundedCornerRadius: CGFloat = 0.0

extension UIView {
    @IBInspectable var roundedSquareView: Bool {
        get {
            return _roundedSquareView
        }
        
        set {
            _roundedSquareView = newValue
            
            if roundedSquareView {
                layer.cornerRadius = self.frame.size.width / 2.0
                contentMode = .scaleAspectFit
            }
        }
    }
    
    @IBInspectable var dropShadowView: Bool {
        get {
            return _dropShadowView
        }
        
        set {
            _dropShadowView = newValue
            
            if dropShadowView {
                layer.shadowColor = UIColor.darkGray.cgColor
                layer.shadowOffset = CGSize(width: 0.75, height: 1.75)
                layer.shadowOpacity = 0.75
                layer.shadowRadius = 5.0
            }
        }
    }
    
    @IBInspectable var roundedCornerRadius: CGFloat {
        get {
            return _roundedCornerRadius
        }
        
        set {
            _roundedCornerRadius = newValue
            
            if roundedCornerRadius > 0.0 {
                layer.cornerRadius = roundedCornerRadius
            }
        }
    }
    
    
}

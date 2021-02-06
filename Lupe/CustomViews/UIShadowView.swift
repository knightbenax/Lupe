//
//  UIViewWithShadow.swift
//  Tremendoc
//
//  Created by Bezaleel Ashefor on 13/01/2019.
//  Copyright © 2019 Tremendoc. All rights reserved.
//

import Foundation
import UIKit

class UIShadowView : UIView {
    
    private var shadowLayer: CAShapeLayer!
    @IBInspectable var shadowRadius: CGFloat = 6.5
    @IBInspectable var shadowWidth: CGFloat = 0.0
    @IBInspectable var shadowHeight: CGFloat = 0.0
    @IBInspectable var shadowColor: UIColor = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.35
    
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowOffset = CGSize(width: shadowWidth, height: shadowHeight)
        layer.shadowColor = shadowColor.cgColor
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
    }
    
}


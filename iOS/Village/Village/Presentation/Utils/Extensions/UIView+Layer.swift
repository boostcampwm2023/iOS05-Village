//
//  UIView+Layer.swift
//  Village
//
//  Created by 조성민 on 11/17/23.
//

import UIKit

extension UIView {
    
    func setLayer(borderWidth: CGFloat = 0.5, borderColor: CGColor = UIColor.grey800.cgColor, cornerRadius: CGFloat = 8) {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor
        layer.cornerRadius = cornerRadius
    }
    
}

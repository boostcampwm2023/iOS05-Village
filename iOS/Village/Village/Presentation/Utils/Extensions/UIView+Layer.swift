//
//  UIView+Layer.swift
//  Village
//
//  Created by 조성민 on 11/17/23.
//

import UIKit

extension UIView {
    
    func setLayer(borderWidth: CGFloat = 1, borderColor: UIColor = .grey800, cornerRadius: CGFloat = 8) {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.cornerRadius = cornerRadius
    }
    
}

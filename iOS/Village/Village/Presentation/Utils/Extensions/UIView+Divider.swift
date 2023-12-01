//
//  UIView+Divider.swift
//  Village
//
//  Created by 정상윤 on 11/21/23.
//

import UIKit

extension UIView {
    
    enum DividerDirection {
        case horizontal
        case vertical
    }
    
    static func divider(_ direction: DividerDirection, width: CGFloat = 1.0, color: UIColor = .systemGray4) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color
        
        if direction == .horizontal {
            view.heightAnchor.constraint(equalToConstant: width).isActive = true
        } else {
            view.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        return view
    }
    
}

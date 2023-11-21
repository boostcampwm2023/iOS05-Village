//
//  UIView+Divider.swift
//  Village
//
//  Created by 정상윤 on 11/21/23.
//

import UIKit

extension UIView {
    
    static var divider: UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        view.backgroundColor = .grey100
        return view
    }
    
}

//
//  UITextField+.swift
//  Village
//
//  Created by 조성민 on 11/18/23.
//

import UIKit

extension UITextField {
    
    func setPlaceHolder(_ placeholder: String) {
        let attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        self.attributedPlaceholder = attributedPlaceholder
    }
    
}

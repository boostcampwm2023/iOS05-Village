//
//  UIStackView+.swift
//  Village
//
//  Created by 조성민 on 11/21/23.
//

import UIKit

extension UIStackView {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    
}

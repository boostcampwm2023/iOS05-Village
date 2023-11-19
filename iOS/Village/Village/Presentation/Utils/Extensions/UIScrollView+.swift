//
//  File.swift
//  Village
//
//  Created by 조성민 on 11/18/23.
//

import UIKit

extension UIStackView {
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    
}

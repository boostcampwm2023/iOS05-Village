//
//  UILabel+SetTitle.swift
//  Village
//
//  Created by 박동재 on 2023/11/15.
//

import UIKit

extension UILabel {
    
    func setTitle(_ title: String) {
        self.text = title
        self.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    }
}

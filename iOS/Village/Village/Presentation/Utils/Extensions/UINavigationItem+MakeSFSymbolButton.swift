//
//  UINavigationItem+MakeSFSymbolButton.swift
//  Village
//
//  Created by 박동재 on 2023/11/15.
//

import UIKit

extension UINavigationItem {
    
    func makeSFSymbolButton(_ target: Any?, action: Selector, symbolName: ImageSystemName) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbolName.rawValue), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
//        button.tintColor = .primary500
        
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
                
        return barButtonItem
    }
}

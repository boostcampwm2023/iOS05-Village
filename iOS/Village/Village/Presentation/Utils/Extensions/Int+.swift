//
//  Int+.swift
//  Village
//
//  Created by 정상윤 on 11/22/23.
//

import Foundation

extension Int {
    
    func priceText() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(for: self)
    }
    
}

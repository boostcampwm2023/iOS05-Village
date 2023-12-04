//
//  NSMutableData+.swift
//  Village
//
//  Created by 조성민 on 12/4/23.
//

import Foundation

extension NSMutableData {
    
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
    
}

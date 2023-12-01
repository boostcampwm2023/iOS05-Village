//
//  Encodable+.swift
//  Village
//
//  Created by 정상윤 on 11/28/23.
//

import Foundation

extension Encodable {
    
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String: Any]
    }
    
}

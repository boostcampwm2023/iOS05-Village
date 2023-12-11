//
//  GetAllReadResponseDTO.swift
//  Village
//
//  Created by 박동재 on 12/11/23.
//

import Foundation

struct GetAllReadResponseDTO: Codable {
    
    let allRead: Bool
    
    enum CodingKeys: String, CodingKey {
        case allRead = "all_read"
    }
    
}

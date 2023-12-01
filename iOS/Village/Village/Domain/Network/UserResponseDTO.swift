//
//  UserResponseDTO.swift
//  Village
//
//  Created by 정상윤 on 11/24/23.
//

import Foundation

struct UserResponseDTO: Decodable {
    
    let nickname: String
    let profileImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case nickname
        case profileImageURL = "profile_img"
    }
    
}

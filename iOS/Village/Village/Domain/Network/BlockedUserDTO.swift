//
//  BlockedUserDTO.swift
//  Village
//
//  Created by 조성민 on 12/10/23.
//

import Foundation

struct BlockedUserDTO: Decodable, Hashable {
    
    let nickname: String
    let profileImageURL: String
    let userID: String
    
    enum CodingKeys: String, CodingKey {
        case nickname
        case profileImageURL = "profile_img"
        case userID = "user_id"
    }
}

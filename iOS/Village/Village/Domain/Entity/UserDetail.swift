//
//  UserDetail.swift
//  Village
//
//  Created by 박동재 on 1/11/24.
//

import Foundation

struct UserDetail: Hashable, Decodable {
    
    let nickname: String
    let profileImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case nickname
        case profileImageURL = "profile_img"
    }
    
}

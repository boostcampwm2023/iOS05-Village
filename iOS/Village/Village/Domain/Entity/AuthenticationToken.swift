//
//  Token.swift
//  Village
//
//  Created by 정상윤 on 11/27/23.
//

import Foundation

struct AuthenticationToken: Codable {
    
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
    
}

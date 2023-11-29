//
//  AppleOAuthDTO.swift
//  Village
//
//  Created by 정상윤 on 11/27/23.
//

import Foundation

struct AppleOAuthDTO: Encodable {
    
    let identityToken: String
    let authorizationCode: String
    
    enum CodingKeys: String, CodingKey {
        case identityToken = "identity_token"
        case authorizationCode = "authorization_code"
    }
    
}

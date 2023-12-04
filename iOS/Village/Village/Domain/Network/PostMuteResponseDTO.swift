//
//  PostMuteResponseDTO.swift
//  Village
//
//  Created by 박동재 on 2023/12/04.
//

import Foundation

struct PostMuteResponseDTO: Hashable, Decodable {
    
    let title: String
    let postID: Int
    let userID: String
    let isRequest: Bool
    let images: [String]
    
    enum CodingKeys: String, CodingKey {
        case title
        case postID = "post_id"
        case userID = "user_id"
        case isRequest = "is_request"
        case images
    }
    
}

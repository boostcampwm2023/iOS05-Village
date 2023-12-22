//
//  PostResponseDTO.swift
//  Village
//
//  Created by 정상윤 on 11/24/23.
//

import Foundation

struct PostResponseDTO: Decodable {
    
    let title: String
    let description: String
    let price: Int?
    let postID: Int
    let userID: String
    let images: [String]
    let isRequest: Bool
    let startDate: String
    let endDate: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case price
        case images
        case postID = "post_id"
        case userID = "user_id"
        case isRequest = "is_request"
        case startDate = "start_date"
        case endDate = "end_date"
    }
    
}

extension PostResponseDTO: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(postID)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.postID == rhs.postID
    }
    
}

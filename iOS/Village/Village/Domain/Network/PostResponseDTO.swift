//
//  PostResponseDTO.swift
//  Village
//
//  Created by 박동재 on 2023/11/22.
//

import Foundation

struct PostResponseDTO: Hashable, Codable {
    
    let title: String
    let price: Int?
    let contents: String
    let postId: Int
    let userId: Int
    let isRequest: Int
    let images: [String]
    let startDate: String
    let endDate: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case price
        case contents
        case postId = "post_id"
        case userId = "user_id"
        case isRequest = "is_request"
        case images
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

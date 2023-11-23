//
//  PostResponseDTO.swift
//  Village
//
//  Created by 박동재 on 2023/11/22.
//

import Foundation

struct PostResponseDTO: Codable {
    
    let title: String
    let price: Int?
    let contents: String
    let postID: Int
    let userID: Int
    let isRequest: Int
    let images: [String]
    let startDate: String
    let endDate: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case price
        case contents
        case postID = "post_id"
        case userID = "user_id"
        case isRequest = "is_request"
        case images
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

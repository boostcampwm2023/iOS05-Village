//
//  PostMuteResponseDTO.swift
//  Village
//
//  Created by 박동재 on 2023/12/04.
//

import Foundation

struct PostMuteResponseDTO: Hashable, Decodable {
    
    let title: String
    let postImage: String?
    let postID: Int
    let isRequest: Bool
    let startDate: String
    let endDate: String
    let price: Int?
    
    enum CodingKeys: String, CodingKey {
        case title
        case postImage = "post_image"
        case postID = "post_id"
        case isRequest = "is_request"
        case startDate = "start_date"
        case endDate = "end_date"
        case price
    }
    
}

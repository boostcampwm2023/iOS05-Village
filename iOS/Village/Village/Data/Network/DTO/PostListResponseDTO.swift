//
//  PostListResponseDTO.swift
//  Village
//
//  Created by 정상윤 on 12/27/23.
//

import Foundation

struct PostListResponseDTO: Decodable {
    
    let title: String
    let price: Int?
    let postID: Int
    let userID: String
    let postImage: String?
    let isRequest: Bool
    let startDate: String
    let endDate: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case price
        case postID = "post_id"
        case userID = "user_id"
        case isRequest = "is_request"
        case postImage = "post_image"
        case startDate = "start_date"
        case endDate = "end_date"
    }
    
}

extension PostListResponseDTO {
    
    func toDomain() -> PostListItem {
        .init(
            title: self.title,
            price: self.price,
            postID: self.postID,
            userID: self.userID,
            thumbnailURL: self.postImage,
            isRequest: self.isRequest,
            startDate: self.startDate,
            endDate: self.endDate
        )
    }
    
}

//
//  PostListItem.swift
//  Village
//
//  Created by 정상윤 on 11/24/23.
//

import Foundation

struct PostListItem {
    
    let title: String
    let price: Int?
    let postID: Int
    let userID: String
    let isRequest: Bool
    let imageURL: String?
    
    init(dto: PostListResponseDTO) {
        self.title = dto.title
        self.price = dto.price
        self.postID = dto.postID
        self.userID = dto.userID
        self.isRequest = dto.isRequest
        self.imageURL = dto.images.first
    }
    
}

extension PostListItem: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.postID == rhs.postID
    }
    
}

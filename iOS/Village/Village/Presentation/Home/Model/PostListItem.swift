//
//  PostListItem.swift
//  Village
//
//  Created by 정상윤 on 11/24/23.
//

import Foundation

struct PostListItem: Hashable {
    
    let title: String
    let price: Int?
    let postID: Int
    let userID: Int
    let isRequest: Int
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

//
//  PostListItem.swift
//  Village
//
//  Created by 정상윤 on 12/27/23.
//

import Foundation

struct PostListItem {
    
    let title: String
    let price: Int?
    let postID: Int
    let userID: String
    let thumbnailURL: String?
    let isRequest: Bool
    let startDate: String
    let endDate: String
    
}

extension PostListItem: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(postID)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.postID == rhs.postID
    }
     
}

//
//  PostListItemViewModel.swift
//  Village
//
//  Created by 박동재 on 2023/11/16.
//

import Foundation

struct VillagePost: Codable {
    let body: [Post]
}

struct Post: Hashable, Codable {
    let title: String
    let price: Int?
    let contents: String
    let postId: Int
    let userId: String
    let isRequest: Bool
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

final class PostListItemViewModel {
    var posts: [Post] = []
    
    func updatePosts(updatePosts: [Post]) {
        self.posts = updatePosts
    }
    
}

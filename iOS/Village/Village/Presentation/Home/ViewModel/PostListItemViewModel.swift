//
//  PostListItemViewModel.swift
//  Village
//
//  Created by 박동재 on 2023/11/16.
//

import Foundation

final class PostListItemViewModel {
    private var posts: [PostResponseDTO] = []
    
    func updatePosts(_ updatePosts: [PostResponseDTO]) {
        self.posts = updatePosts
    }
    
    func getPosts() -> [PostResponseDTO] {
        return posts
    }
    
    func getPost(_ index: Int) -> PostResponseDTO {
        return posts[index]
    }
    
}

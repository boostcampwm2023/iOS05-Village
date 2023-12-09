//
//  MyHiddenPostsViewModel.swift
//  Village
//
//  Created by 조성민 on 12/9/23.
//

import Foundation

final class MyHiddenPostsViewModel {
    
    var posts: [PostMuteResponseDTO] = []
    
    func transform(input: Input) -> Output {
        
        return Output()
    }
    
    init() {
        getMyHiddenPosts()
    }
    
    private func getMyHiddenPosts() {
        
    }
    
}

extension MyHiddenPostsViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
}

//
//  MyPostsViewModel.swift
//  Village
//
//  Created by 조성민 on 12/5/23.
//

import Foundation

final class MyPostsViewModel {
    
    var requestPosts: [PostListResponseDTO] = []
    var rentPosts: [PostListResponseDTO] = []
    
    init() {
        
        let endpoint = APIEndPoints.getPosts(
            queryParameter: GetPostsQueryDTO(
                searchKeyword: nil,
                requestFilter: nil,
                writer: "rNm8fmql",// TODO: current User Id
                page: nil
            )
        )
        
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                dump(data)
                
            } catch {
                dump(error)
            }
        }
        
    }
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
}

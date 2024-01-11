//
//  DefaultPostDetailRepostory.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation
import Combine

struct DefaultPostDetailRepostory: PostDetailRepository {
    
    typealias ResponseDTO = PostResponseDTO
    
    private func makeEndPoint(postID: Int) -> EndPoint<PostResponseDTO> {
        return EndPoint(
            baseURL: Constant.baseURL,
            path: "posts/\(postID)",
            method: .GET
        )
    }
    
    func fetchPostData(postID: Int) -> AnyPublisher<PostDetail, NetworkError> {
        let endpoint = makeEndPoint(postID: postID)
        
        return NetworkService.shared.request(endpoint)
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
    
}

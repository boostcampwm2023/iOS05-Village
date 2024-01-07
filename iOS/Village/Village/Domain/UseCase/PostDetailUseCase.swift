//
//  PostDetailUseCase.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation

struct PostDetailUseCase: UseCase {
    
    private let repository: DefaultPostDetailRepostory
    private let postID: Int
    private let completion: (Result<PostResponseDTO, NetworkError>) -> Void

    init(
        repository: DefaultPostDetailRepostory,
        postID: Int,
        completion: @escaping (Result<PostResponseDTO, NetworkError>) -> Void
    ) {
        self.repository = repository
        self.postID = postID
        self.completion = completion
    }
    
    func start() {
        Task {
            let result = await repository.fetchPostData(postID: postID)
            completion(result)
        }
    }
    
}

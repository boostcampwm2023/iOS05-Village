//
//  PostDetailUseCase.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation
import Combine

struct PostDetailUseCase: UseCase {
    
    typealias ResultValue = PostDetail
    
    private let repository: DefaultPostDetailRepostory
    private let postID: Int

    init(
        repository: DefaultPostDetailRepostory,
        postID: Int
    ) {
        self.repository = repository
        self.postID = postID
    }
    
    func start() -> AnyPublisher<ResultValue, NetworkError> {
        repository
            .fetchPostData(postID: postID)
            .eraseToAnyPublisher()
    }
    
}

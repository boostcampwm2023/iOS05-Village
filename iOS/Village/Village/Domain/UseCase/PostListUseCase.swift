//
//  PostListUseCase.swift
//  Village
//
//  Created by 정상윤 on 12/27/23.
//

import Foundation
import Combine

struct PostListUseCase: UseCase {
    
    typealias ResultValue = [PostListItem]
    
    struct RequestValue {
        let searchKeyword: String? = nil
        let postType: PostType
        let writer: String? = nil
        let lastID: String?
    }
    
    private let repository: DefaultPostListRepository
    private let requestValue: RequestValue
    
    init(repository: DefaultPostListRepository,
         requestValue: RequestValue
    ) {
        self.repository = repository
        self.requestValue = requestValue
    }
    
    func start() -> AnyPublisher<ResultValue, NetworkError> {
        repository
            .fetchPostList(
                searchKeyword: requestValue.searchKeyword,
                postType: requestValue.postType,
                writer: requestValue.writer,
                lastID: requestValue.lastID)
            .eraseToAnyPublisher()
    }
    
}

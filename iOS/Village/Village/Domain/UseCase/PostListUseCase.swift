//
//  PostListUseCase.swift
//  Village
//
//  Created by 정상윤 on 12/27/23.
//

import Foundation
import Combine

struct PostListUseCase: UseCase {
    
    struct RequestValue {
        let searchKeyword: String? = nil
        let postType: PostType
        let writer: String? = nil
        let lastID: String?
    }
    
    private let repository: DefaultPostListRepository
    private let requestValue: RequestValue
    private let completion: (Result<[PostListItem], Error>) -> Void
    
    init(repository: DefaultPostListRepository,
         requestValue: RequestValue,
         completion: @escaping (Result<[PostListItem], Error>) -> Void
    ) {
        self.repository = repository
        self.requestValue = requestValue
        self.completion = completion
    }
    
    func start() {
        Task {
            let result = await repository.fetchPostList(
                searchKeyword: requestValue.searchKeyword,
                postType: requestValue.postType,
                writer: requestValue.writer,
                lastID: requestValue.lastID
            )
            completion(result)
        }
    }
    
}

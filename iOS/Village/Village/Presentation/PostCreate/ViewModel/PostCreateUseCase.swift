//
//  PostCreateUseCase.swift
//  Village
//
//  Created by 조성민 on 11/24/23.
//

import Foundation
import Combine

final class PostCreateUseCase {
    
    private let postCreateRepository: PostCreateRepository
    
    init(postCreateRepository: PostCreateRepository) {
        self.postCreateRepository = postCreateRepository
    }
    
//    func execute(
//        requestValue: PostCreateDTO,
//        completion: @escaping (Result<Void, Error>) -> Void
//    ) -> Cancellable? {
//        return postCreateRepository.postCreate(
//            postCreateDTO: requestValue
//        )
//    }
    
}

//
//  PostCreateUseCase.swift
//  Village
//
//  Created by 조성민 on 11/24/23.
//

import Foundation

final class PostCreateUseCase: PostUseCase {
    
    private let postCreateRepository: PostCreateRepository
    
    init(postCreateRepository: PostCreateRepository) {
        self.postCreateRepository = postCreateRepository
    }
    
    func execute(with post: PostModifyDTO) {
        
        let endPoint = APIEndPoints.modifyPost(
            with: post
        )
        Task {
            do {
                try await APIProvider.shared.multipartRequest(with: endPoint)
            } catch {
                dump(error)
            }
        }
        
    }
    
}

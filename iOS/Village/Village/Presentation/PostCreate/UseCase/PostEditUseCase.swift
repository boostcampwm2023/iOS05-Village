//
//  PostEditUseCase.swift
//  Village
//
//  Created by 조성민 on 12/4/23.
//

import Foundation

final class PostEditUseCase: PostUseCase {
    
    private let postCreateRepository: PostCreateRepository
    var postID: Int?
    
    init(postCreateRepository: PostCreateRepository) {
        self.postCreateRepository = postCreateRepository
    }
    
    func execute(with post: PostModifyDTO) {
        guard let id = postID else { return }
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

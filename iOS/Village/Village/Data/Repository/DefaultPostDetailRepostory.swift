//
//  DefaultPostDetailRepostory.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation

struct DefaultPostDetailRepostory: PostDetailRepository {
    
    typealias ResponseDTO = PostResponseDTO
    
    private func makeEndPoint(postID: Int) -> EndPoint<PostResponseDTO> {
        return EndPoint(
            baseURL: Constant.baseURL,
            path: "posts/\(postID)",
            method: .GET
        )
    }
    
    func fetchPostData(postID: Int) async -> Result<PostResponseDTO, NetworkError> {
        let endpoint = makeEndPoint(postID: postID)
        
        do {
            guard let responseDTO = try await APIProvider.shared.request(with: endpoint) else {
                return .failure(.emptyData)
            }
            return .success(responseDTO)
        } catch let error as NetworkError {
            return .failure(error)
        } catch {
            return .failure(.unknownError)
        }
    }
    
}

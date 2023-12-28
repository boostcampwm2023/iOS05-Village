//
//  DefaultPostListRepository.swift
//  Village
//
//  Created by 정상윤 on 12/27/23.
//

import Foundation

struct DefaultPostListRepository: PostListRepository {
    
    typealias ResponseDTO = PostListResponseDTO
    typealias RequestDTO = PostListRequestDTO
    
    func fetchPostList(
        searchKeyword: String?,
        postType: PostType,
        writer: String?,
        lastID: String?
    ) async -> Result<[PostListItem], Error> {
        let endpoint = makeEndPoint(
            searchKeyword: searchKeyword,
            postType: postType,
            writer: writer,
            lastID: lastID
        )
        
        do {
            guard let postListDTO = try await APIProvider.shared.request(with: endpoint) else {
                return .success([])
            }
            return .success(postListDTO.map { $0.toDomain() })
        } catch {
            return .failure(error)
        }
    }
    
    private func makeEndPoint(
        searchKeyword: String?,
        postType: PostType,
        writer: String?,
        lastID: String?
    ) -> EndPoint<[ResponseDTO]> {
        let requestDTO = RequestDTO(
            searchKeyword: searchKeyword,
            requestFilter: "\(postType.rawValue)",
            writer: writer,
            lastID: lastID
        )
        
        return EndPoint(
            baseURL: Constant.baseURL,
            path: "posts",
            method: .GET,
            queryParameters: requestDTO
        )
    }
    
}

//
//  DefaultPostListRepository.swift
//  Village
//
//  Created by 정상윤 on 12/27/23.
//

import Foundation
import Combine

struct DefaultPostListRepository: PostListRepository {
    
    typealias RequestDTO = PostListRequestDTO
    typealias ResponseDTO = PostListResponseDTO
    
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
    
    func fetchPostList(
        searchKeyword: String?,
        postType: PostType,
        writer: String?,
        lastID: String?
    ) -> AnyPublisher<[PostListItem], NetworkError> {
        let endpoint = makeEndPoint(
            searchKeyword: searchKeyword,
            postType: postType,
            writer: writer,
            lastID: lastID
        )

        return NetworkService.shared.request(endpoint)
            .map({ dto in
                dto.map { $0.toDomain() }
            })
            .eraseToAnyPublisher()
    }
    
}

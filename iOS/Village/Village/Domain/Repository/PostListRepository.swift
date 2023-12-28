//
//  PostListRepository.swift
//  Village
//
//  Created by 정상윤 on 12/27/23.
//

import Foundation

protocol PostListRepository {
    
    associatedtype RequestDTO
    associatedtype ResponseDTO
    
    func fetchPostList(
        searchKeyword: String?,
        postType: PostType,
        writer: String?,
        lastID: String?
    ) async -> Result<[PostListItem], Error>
    
}

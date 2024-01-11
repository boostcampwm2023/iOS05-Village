//
//  PostDetailRepository.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation
import Combine

protocol PostDetailRepository {
    
    associatedtype ResponseDTO
    
    func fetchPostData(postID: Int) -> AnyPublisher<PostDetail, NetworkError>
    
}

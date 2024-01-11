//
//  DefaultUserDetailRepository.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation
import Combine

struct DefaultUserDetailRepository: UserDetailRepository {
    
    typealias ResponseDTO = UserResponseDTO
    
    private func makeEndPoint(userID: String) -> EndPoint<UserResponseDTO> {
        return EndPoint(
            baseURL: Constant.baseURL,
            path: "users/\(userID)",
            method: .GET
        )
    }
    
    func fetchUserData(userID: String) -> AnyPublisher<UserDetail, NetworkError> {
        let endpoint = makeEndPoint(userID: userID)
        
        return NetworkService.shared.request(endpoint)
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
    
}

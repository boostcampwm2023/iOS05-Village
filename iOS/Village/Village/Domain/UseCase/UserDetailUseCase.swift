//
//  UserDetailUseCase.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation

struct UserDetailUseCase: UseCase {
    
    private let repository: DefaultUserDetailRepository
    private let userID: String
    private let completion: (Result<UserResponseDTO, NetworkError>) -> Void
    
    init(
        repository: DefaultUserDetailRepository,
        userID: String,
        completion: @escaping (Result<UserResponseDTO, NetworkError>) -> Void
    ) {
        self.repository = repository
        self.userID = userID
        self.completion = completion
    }
    
    func start() {
        Task {
            let result = await repository.fetchUserData(userID: userID)
            completion(result)
        }
    }
    
}

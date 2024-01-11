//
//  UserDetailUseCase.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation
import Combine

struct UserDetailUseCase: UseCase {
    
    typealias ResultValue = UserDetail
    
    private let repository: DefaultUserDetailRepository
    private let userID: String
    
    init(
        repository: DefaultUserDetailRepository,
        userID: String
    ) {
        self.repository = repository
        self.userID = userID
    }
    
    func start() -> AnyPublisher<ResultValue, NetworkError> {
        repository
            .fetchUserData(userID: userID)
            .eraseToAnyPublisher()
    }
    
}

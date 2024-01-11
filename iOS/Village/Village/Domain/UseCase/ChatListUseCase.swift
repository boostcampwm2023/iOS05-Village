//
//  ChatListUseCase.swift
//  Village
//
//  Created by 박동재 on 1/6/24.
//

import Foundation
import Combine

struct ChatListUseCase: UseCase {
    
    typealias ResultValue = ChatList
    
    private let repository: DefaultChatListRepository

    init(repository: DefaultChatListRepository
    ) {
        self.repository = repository
    }
    
    func start() -> AnyPublisher<ResultValue, NetworkError> {
        repository
            .fetchChatList()
            .eraseToAnyPublisher()
    }
    
}

//
//  ChatListUseCase.swift
//  Village
//
//  Created by 박동재 on 1/6/24.
//

import Foundation

struct ChatListUseCase: UseCase {
    
    private let repository: DefaultChatListRepository
    private let completion: (Result<GetChatListResponseDTO, NetworkError>) -> Void

    init(repository: DefaultChatListRepository, 
         completion: @escaping (Result<GetChatListResponseDTO, NetworkError>) -> Void
    ) {
        self.repository = repository
        self.completion = completion
    }
    
    func start() {
        Task {
            let result = await repository.fetchChatList()
            completion(result)
        }
    }
    
}

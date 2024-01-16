//
//  DeleteChatUseCase.swift
//  Village
//
//  Created by 박동재 on 1/16/24.
//

import Foundation
import Combine

struct DeleteChatUseCase: UseCase {
    
    typealias ResultValue = Void
    
    private let repository: DeleteChatRepository
    private let roomID: Int
    
    init(repository: DeleteChatRepository, roomID: Int) {
        self.repository = repository
        self.roomID = roomID
    }
    
    func start() -> AnyPublisher<Void, NetworkError> {
        return repository
            .deleteChat(roomID: roomID)
            .eraseToAnyPublisher()
    }
    
}

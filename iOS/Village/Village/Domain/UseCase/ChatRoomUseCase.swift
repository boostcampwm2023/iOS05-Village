//
//  ChatRoomUseCase.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation
import Combine

struct ChatRoomUseCase: UseCase {
    
    typealias ResultValue = ChatRoom
    
    private let repository: DefaultChatRoomRepository
    private let roomID: Int
    
    init(repository: DefaultChatRoomRepository,
         roomID: Int
    ) {
        self.repository = repository
        self.roomID = roomID
    }
    
    func start() -> AnyPublisher<ResultValue, NetworkError> {
        repository
            .fetchRoomData(roomID: roomID)
            .eraseToAnyPublisher()
    }
    
}

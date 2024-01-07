//
//  ChatRoomUseCase.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation

struct ChatRoomUseCase: UseCase {
    
    private let repository: DefaultChatRoomRepository
    private let roomID: Int
    private let completion: (Result<ChatRoomResponseDTO, NetworkError>) -> Void
    
    init(repository: DefaultChatRoomRepository,
         roomID: Int,
         completion: @escaping (Result<ChatRoomResponseDTO, NetworkError>) -> Void
    ) {
        self.repository = repository
        self.roomID = roomID
        self.completion = completion
    }
    
    func start() {
        Task {
            let result = await repository.fetchRoomData(roomID: roomID)
            completion(result)
        }
    }
    
}

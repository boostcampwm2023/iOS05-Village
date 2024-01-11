//
//  DefaultChatListRepository.swift
//  Village
//
//  Created by 박동재 on 1/6/24.
//

import Foundation
import Combine

struct DefaultChatListRepository: ChatListRepository {
    
    private func makeEndPoint() -> EndPoint<ChatListResponseDTO> {
        return EndPoint(
            baseURL: Constant.baseURL,
            path: "chat/room",
            method: .GET
        )
    }
    
    func fetchChatList() -> AnyPublisher<ChatList, NetworkError> {
        let endpoint = makeEndPoint()
        
        return NetworkService.shared.request(endpoint)
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
    
}

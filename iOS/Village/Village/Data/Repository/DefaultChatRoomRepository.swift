//
//  DefaultChatRoomRepository.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation
import Combine

struct DefaultChatRoomRepository: ChatRoomRepository {
    
    typealias ResponseDTO = ChatRoomResponseDTO
    
    private func makeEndPoint(roomID: Int) -> EndPoint<ChatRoomResponseDTO> {
        return EndPoint(
            baseURL: Constant.baseURL,
            path: "chat/room/\(roomID)",
            method: .GET
        )
    }
    
    func fetchRoomData(roomID: Int) -> AnyPublisher<ChatRoom, NetworkError> {
        let endpoint = makeEndPoint(roomID: roomID)
        
        return NetworkService.shared.request(endpoint)
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
    
}

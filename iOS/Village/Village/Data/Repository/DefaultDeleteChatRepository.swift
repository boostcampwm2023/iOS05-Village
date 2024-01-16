//
//  DefaultDeleteChatRepository.swift
//  Village
//
//  Created by 박동재 on 1/16/24.
//

import Foundation
import Combine

struct DefaultDeleteChatRepository: DeleteChatRepository {
    
    private func makeEndPoint(roomID: Int) -> EndPoint<Void> {
        return EndPoint(
            baseURL: Constant.baseURL,
            path: "chat/leave/\(roomID)",
            method: .PATCH
        )
    }
    
    func deleteChat(roomID: Int) -> AnyPublisher<Void, NetworkError> {
        let endpoint = makeEndPoint(roomID: roomID)
        return NetworkService.shared.request(endpoint)
            .eraseToAnyPublisher()
    }
    
}

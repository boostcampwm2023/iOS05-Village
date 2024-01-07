//
//  DefaultChatListRepository.swift
//  Village
//
//  Created by 박동재 on 1/6/24.
//

import Foundation

struct DefaultChatListRepository: ChatListRepository {
    
    private func makeEndPoint() -> EndPoint<GetChatListResponseDTO> {
        return EndPoint(
            baseURL: Constant.baseURL,
            path: "chat/room",
            method: .GET
        )
    }
    
    func fetchChatList() async -> Result<GetChatListResponseDTO, NetworkError> {
        let endpoint = makeEndPoint()
        
        do {
            guard let chatListDTO = try await APIProvider.shared.request(with: endpoint) else {
                return .success(GetChatListResponseDTO(allRead: true, chatList: []))
            }
            return .success(chatListDTO)
        } catch let error as NetworkError {
            return .failure(error)
        } catch {
            return .failure(.unknownError)
        }
    }
    
}

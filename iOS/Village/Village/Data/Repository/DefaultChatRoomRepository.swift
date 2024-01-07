//
//  DefaultChatRoomRepository.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation

struct DefaultChatRoomRepository: ChatRoomRepository {
    
    typealias ResponseDTO = ChatRoomResponseDTO
    
    private func makeEndPoint(roomID: Int) -> EndPoint<ChatRoomResponseDTO  > {
        return EndPoint(
            baseURL: Constant.baseURL,
            path: "chat/room/\(roomID)",
            method: .GET
        )
    }
    
    func fetchRoomData(roomID: Int) async -> Result<ChatRoomResponseDTO, NetworkError> {
        let endpoint = makeEndPoint(roomID: roomID)
        
        do {
            guard let roomDataDTO = try await APIProvider.shared.request(with: endpoint) else {
                return .failure(.emptyData)
            }
            return .success(roomDataDTO)
        } catch let error as NetworkError {
            return .failure(error)
        } catch {
            return .failure(.unknownError)
        }
    }
    
}

//
//  ChatRoomRepository.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation

protocol ChatRoomRepository {
    
    associatedtype ResponseDTO
    
    func fetchRoomData(roomID: Int) async -> Result<ChatRoomResponseDTO, NetworkError>
    
}

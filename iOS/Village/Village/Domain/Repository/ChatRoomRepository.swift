//
//  ChatRoomRepository.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation
import Combine

protocol ChatRoomRepository {
    
    func fetchRoomData(roomID: Int) -> AnyPublisher<ChatRoom, NetworkError>
    
}

//
//  ChatListRepository.swift
//  Village
//
//  Created by 박동재 on 1/6/24.
//

import Foundation
import Combine

protocol ChatListRepository {
    
    func fetchChatList() -> AnyPublisher<ChatList, NetworkError>
    
}

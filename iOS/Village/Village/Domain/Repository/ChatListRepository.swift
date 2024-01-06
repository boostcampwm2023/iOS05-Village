//
//  ChatListRepository.swift
//  Village
//
//  Created by 박동재 on 1/6/24.
//

import Foundation

protocol ChatListRepository {
    
    func fetchChatList() async -> Result<GetChatListResponseDTO, Error>
    
}

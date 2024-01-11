//
//  ChatListResponseDTO.swift
//  Village
//
//  Created by 박동재 on 12/6/23.
//

import Foundation

struct ChatListResponseDTO: Hashable, Codable {
    
    let allRead: Bool
    let chatList: [ChatListItemDTO]
    
    enum CodingKeys: String, CodingKey {
        case allRead = "all_read"
        case chatList = "chat_list"
    }
    
}

extension ChatListResponseDTO {

    func toDomain() -> ChatList {
        .init(
            allRead: self.allRead,
            chatList: self.chatList.map { $0.toDomain() }
        )
    }
    
}

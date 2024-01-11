//
//  ChatDTO.swift
//  Village
//
//  Created by 박동재 on 1/10/24.
//

import Foundation

struct ChatDTO: Hashable, Codable {
    
    let id: Int
    let message: String
    let sender: String
    let chatRoom: Int
    let isRead: Bool
    let createDate: String
    let deleteDate: String?
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case message
        case sender
        case chatRoom = "chat_room"
        case isRead = "is_read"
        case createDate = "create_date"
        case deleteDate = "delete_date"
        case count
    }
    
}

extension ChatDTO {
    
    func toDomain() -> Chat {
        .init(
            id: self.id,
            message: self.message,
            sender: self.sender,
            chatRoom: self.chatRoom,
            isRead: self.isRead,
            createDate: self.createDate,
            deleteDate: self.deleteDate,
            count: self.count)
    }
    
}

//
//  GetRoomResponseDTO.swift
//  Village
//
//  Created by 박동재 on 2023/12/05.
//

import Foundation

struct Chat: Hashable, Codable {
    
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

struct GetRoomResponseDTO: Codable {
    
    let postID: Int
    let chatLog: [Chat]
    
    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case chatLog = "chat_log"
    }
    
}

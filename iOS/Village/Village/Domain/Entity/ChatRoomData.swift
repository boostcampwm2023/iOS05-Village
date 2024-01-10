//
//  ChatRoomData.swift
//  Village
//
//  Created by 박동재 on 1/10/24.
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

struct ChatRoom: Codable {
    
    let writer: String
    let writerProfileIMG: String
    let user: String
    let userProfileIMG: String
    let postID: Int
    let chatLog: [Chat]
    
    enum CodingKeys: String, CodingKey {
        case writer
        case writerProfileIMG = "writer_profile_img"
        case user
        case userProfileIMG = "user_profile_img"
        case postID = "post_id"
        case chatLog = "chat_log"
    }
    
}

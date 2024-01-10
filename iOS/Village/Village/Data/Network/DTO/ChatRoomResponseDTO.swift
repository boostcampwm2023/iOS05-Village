//
//  ChatRoomResponseDTO.swift
//  Village
//
//  Created by 박동재 on 2023/12/05.
//

import Foundation

struct ChatRoomResponseDTO: Codable {
    
    let writer: String
    let writerProfileIMG: String
    let user: String
    let userProfileIMG: String
    let postID: Int
    let chatLog: [ChatDTO]
    
    enum CodingKeys: String, CodingKey {
        case writer
        case writerProfileIMG = "writer_profile_img"
        case user
        case userProfileIMG = "user_profile_img"
        case postID = "post_id"
        case chatLog = "chat_log"
    }
    
}

extension ChatRoomResponseDTO {
    
    func toDomain() -> ChatRoom {
        .init(
            writer: self.writer,
            writerProfileIMG: self.writerProfileIMG,
            user: self.user,
            userProfileIMG: self.userProfileIMG,
            postID: self.postID,
            chatLog: self.chatLog.map { $0.toDomain() }
        )
    }
    
}

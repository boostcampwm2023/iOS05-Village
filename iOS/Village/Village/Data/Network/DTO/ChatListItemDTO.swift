//
//  ChatListItemDTO.swift
//  Village
//
//  Created by 박동재 on 1/11/24.
//

import Foundation

struct ChatListItemDTO: Hashable, Codable {

    let roomID: Int
    let writer: String?
    let writerProfileIMG: String?
    let writerNickname: String?
    let user: String?
    let userProfileIMG: String?
    let userNickname: String?
    let postID: Int
    let postTitle: String?
    let postThumbnail: String?
    let lastChat: String?
    let lastChatDate: String?
    let allRead: Bool

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case writer
        case writerProfileIMG = "writer_profile_img"
        case writerNickname = "writer_nickname"
        case user
        case userProfileIMG = "user_profile_img"
        case userNickname = "user_nickname"
        case postID = "post_id"
        case postTitle = "post_title"
        case postThumbnail = "post_thumbnail"
        case lastChat = "last_chat"
        case lastChatDate = "last_chat_date"
        case allRead = "all_read"
    }
    
}

extension ChatListItemDTO {
    
    func toDomain() -> ChatListItem {
        .init(
            roomID: self.roomID,
            writer: self.writer,
            writerProfileIMG: self.writerProfileIMG,
            writerNickname: self.writerNickname,
            user: self.user,
            userProfileIMG: self.userProfileIMG,
            userNickname: self.userNickname,
            postID: self.postID,
            postTitle: self.postTitle,
            postThumbnail: self.postThumbnail,
            lastChat: self.lastChat,
            lastChatDate: self.lastChatDate,
            allRead: self.allRead)
    }
    
}

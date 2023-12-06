//
//  GetChatListResponseDTO.swift
//  Village
//
//  Created by 박동재 on 12/6/23.
//

import Foundation

struct GetChatListResponseDTO: Hashable, Codable {

    let roomID: String
    let writer: String?
    let writerProfileIMG: String
    let user: String
    let userProfileIMG: String?
    let postID: String?
    let postTitle: String?
    let postThumbnail: String?
    let lastChat: String?
    let lastChatDate: String?

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case writer
        case writerProfileIMG = "writer_profile_img"
        case user = "recent_chat"
        case userProfileIMG = "user_profile_img"
        case postID = "post_id"
        case postTitle = "post_title"
        case postThumbnail = "post_thumbnail"
        case lastChat = "last_chat"
        case lastChatDate = "last_chat_date"
    }
    
}

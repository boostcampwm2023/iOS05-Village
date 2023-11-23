//
//  ChatListViewModel.swift
//  Village
//
//  Created by 박동재 on 2023/11/23.
//

import Foundation

struct ChatListResponseDTO: Hashable, Codable {
    
    let user: String
    let userProfile: String?
    let recentTime: String
    let recentChat: String
    let postImage: String?
    
    enum CodingKeys: String, CodingKey {
        case user
        case userProfile = "user_profile"
        case recentTime = "recent_time"
        case recentChat = "recent_chat"
        case postImage = "post_image"
    }
    
}

final class ChatListViewModel {
    
    private var chatList: [ChatListResponseDTO] = []
    
    func updateChatList(_ updateChatList: [ChatListResponseDTO]) {
        chatList = updateChatList
    }
    
    func getChatList() -> [ChatListResponseDTO] {
        return chatList
    }
    
}

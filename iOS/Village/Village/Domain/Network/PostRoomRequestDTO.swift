//
//  PostRoomRequestDTO.swift
//  Village
//
//  Created by 박동재 on 2023/12/04.
//

import Foundation

struct PostRoomRequestDTO: Codable {
    
    let writer: String
    let postID: Int
    
    enum CodingKeys: String, CodingKey {
        case writer
        case postID = "post_id"
    }
    
}

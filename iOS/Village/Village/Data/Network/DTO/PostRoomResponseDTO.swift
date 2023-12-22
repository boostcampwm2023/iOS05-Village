//
//  PostRoomResponseDTO.swift
//  Village
//
//  Created by 박동재 on 2023/12/04.
//

import Foundation

struct PostRoomResponseDTO: Codable {
    
    let roomID: Int
    
    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
    }
    
}

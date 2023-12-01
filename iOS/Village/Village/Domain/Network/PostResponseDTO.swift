//
//  PostResponseDTO.swift
//  Village
//
//  Created by 정상윤 on 11/24/23.
//

import Foundation

struct PostResponseDTO: Decodable {
    
    let title: String
    let description: String
    let price: Int?
    let userID: String
    let imageURL: [String]
    let isRequest: Bool
    let startDate: String
    let endDate: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case price
        case userID = "user_id"
        case imageURL = "images"
        case isRequest = "is_request"
        case startDate = "start_date"
        case endDate = "end_date"
    }
    
}

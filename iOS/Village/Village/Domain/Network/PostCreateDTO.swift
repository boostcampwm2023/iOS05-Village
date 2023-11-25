//
//  PostCreateDTO.swift
//  Village
//
//  Created by 조성민 on 11/24/23.
//

import Foundation

struct PostCreateDTO: Codable {
    
    let title: String
    let description: String
    let price: Int?
    let isRequest: Bool
    let image: [Data]
    let startDate: String
    let endDate: String    
    
    enum CodingKeys: String, CodingKey {
        case title
        case price
        case description
        case isRequest = "is_request"
        case image
        case startDate = "start_date"
        case endDate = "end_date"
    }
    
}

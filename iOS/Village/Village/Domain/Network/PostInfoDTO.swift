//
//  PostInfoDTO.swift
//  Village
//
//  Created by 조성민 on 12/4/23.
//

import Foundation

struct PostInfoDTO: Encodable {
    
    let title: String
    let description: String
    let price: Int?
    let isRequest: Bool
    let startDate: String
    let endDate: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case price
        case description
        case isRequest = "is_request"
        case startDate = "start_date"
        case endDate = "end_date"
    }
    
}

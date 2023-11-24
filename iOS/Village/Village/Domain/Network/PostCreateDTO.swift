//
//  PostCreateDTO.swift
//  Village
//
//  Created by 조성민 on 11/24/23.
//

import Foundation

struct PostCreateDTO {
    
    let title: String
    let contents: String
    let price: Int?
    let isRequest: Bool
    let images: [String]
    let startDate: String
    let endDate: String    
    
    enum CodingKeys: String, CodingKey {
        case title
        case price
        case contents
        case isRequest = "is_request"
        case images
        case startDate = "start_date"
        case endDate = "end_date"
    }
    
}

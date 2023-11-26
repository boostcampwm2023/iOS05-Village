//
//  PostCreateDTO.swift
//  Village
//
//  Created by 조성민 on 11/24/23.
//

import Foundation

struct PostCreateInfo: Codable {
    
    let postInfo: PostInfoDTO
    let images: [ImageDTO]
    
}

struct PostInfoDTO: Codable {
    
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

struct ImageDTO: Codable {
    let fileName: String
    let type: String
    let data: Data
    
    enum CodingKeys: String, CodingKey {
        case fileName = "filename"
        case type
        case data
    }
}

//
//  ReportDTO.swift
//  Village
//
//  Created by 조성민 on 12/11/23.
//

import Foundation

struct ReportDTO: Encodable {
    
    let postID: Int
    let userID: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case userID = "user_id"
        case description
    }
    
}

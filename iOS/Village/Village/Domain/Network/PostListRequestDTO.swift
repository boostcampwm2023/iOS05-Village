//
//  PostRequestDTO.swift
//  Village
//
//  Created by 박동재 on 2023/11/22.
//

import Foundation

struct PostListRequestDTO: Codable {
    
    let page: Int
    
    enum CodingKeys: String, CodingKey {
        case page
    }
    
}

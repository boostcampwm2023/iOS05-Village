//
//  GetPostsQueryDTO.swift
//  Village
//
//  Created by 조성민 on 12/6/23.
//

import Foundation

struct GetPostsQueryDTO: Encodable {
    
    let searchKeyword: String?
    let requestFilter: String?
    let writer: String?
    let page: String?
    
    enum CodingKeys: String, CodingKey {
        case searchKeyword
        case requestFilter
        case writer
        case page
    }
    
}

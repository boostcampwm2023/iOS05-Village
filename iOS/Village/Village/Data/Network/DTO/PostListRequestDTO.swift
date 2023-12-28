//
//  PostRequestDTO.swift
//  Village
//
//  Created by 박동재 on 2023/11/22.
//

import Foundation

struct PostListRequestDTO: Encodable {
    
    let searchKeyword: String?
    let requestFilter: String?
    let writer: String?
    let cursorID: String?
    
    init(
        searchKeyword: String? = nil,
        requestFilter: String? = nil,
        writer: String? = nil,
        lastID: String? = nil
    ) {
        self.searchKeyword = searchKeyword
        self.requestFilter = requestFilter
        self.writer = writer
        self.cursorID = lastID
    }
    
    enum CodingKeys: String, CodingKey {
        case searchKeyword
        case requestFilter
        case writer
        case cursorID = "cursorId"
    }
    
}

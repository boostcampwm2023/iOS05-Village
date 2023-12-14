//
//  PostType.swift
//  Village
//
//  Created by 정상윤 on 12/11/23.
//

import Foundation

enum PostType {
    case rent
    case request
    
    init(isRequest: Bool) {
        self = isRequest ? .request : .rent
    }
}

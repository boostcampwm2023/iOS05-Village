//
//  PostModifyRequestDTO.swift
//  Village
//
//  Created by 조성민 on 11/24/23.
//

import Foundation

struct PostModifyRequestDTO: Encodable, MultipartFormData {
    
    let postInfo: PostInfoDTO
    let image: [Data]
    var postID: Int?
    let boundary = UUID().uuidString
    
    var httpBody: Data {
        let body = NSMutableData()
        
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"post_info\"\r\n"
        fieldString += "\r\n"
        
        if let dictionary = try? postInfo.toDictionary(),
           !dictionary.isEmpty,
           let data = try? JSONSerialization.data(withJSONObject: dictionary),
           let string = String(data: data, encoding: .utf8) {
            fieldString += "\(string)\r\n"
        }
        
        body.appendString(fieldString)
        
        image.forEach { image in
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n")
            body.appendString("Content-Type: image\r\n\r\n")
            body.append(image)
            body.appendString("\r\n")
        }
        body.appendString("--\(boundary)--")
        
        return body as Data
    }
    
    enum CodingKeys: String, CodingKey {
        case postInfo = "post_info"
        case image
    }
    
}

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

extension NSMutableData {
    
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
    
}

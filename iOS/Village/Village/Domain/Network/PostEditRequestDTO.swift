//
//  PostEditRequestDTO.swift
//  Village
//
//  Created by 조성민 on 12/4/23.
//

import Foundation

struct PostEditRequestDTO: Encodable, MultipartFormData {
    
    let postInfo: PostInfoDTO
    let image: [Data]
    let postID: Int
    let boundary = UUID().uuidString
    
    var httpBody: Data {
        var body = NSMutableData()
        
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
            body.appendString("Content-Disposition: form-data; name=\"image\";\r\n")
            body.appendString("Content-Type: image\r\n\r\n")
            body.append(image)
            body.appendString("\r\n")
        }
        body.appendString("--\(boundary)--")
        
        return body as Data
    }
    
    
}

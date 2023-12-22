//
//  PatchUserDTO.swift
//  Village
//
//  Created by 조성민 on 12/9/23.
//

import Foundation

struct PatchUserInfo: Encodable {
    let nickname: String?
}

struct PatchUserDTO: Encodable, MultipartFormData {
    
    let userInfo: PatchUserInfo?
    let image: Data?
    let userID: String
    var boundary: String = UUID().uuidString
    var httpBody: Data {
        let body = NSMutableData()
        
        var fieldString = ""
        if let dictionary = try? userInfo.toDictionary(),
           !dictionary.isEmpty,
           let data = try? JSONSerialization.data(withJSONObject: dictionary),
           let string = String(data: data, encoding: .utf8) {
            fieldString += "--\(boundary)\r\n"
            fieldString += "Content-Disposition: form-data; name=\"profile\"\r\n"
            fieldString += "\r\n"
            fieldString += "\(string)\r\n"
        }
        
        body.appendString(fieldString)
        
        if let image = image {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n")
            body.appendString("Content-Type: image\r\n\r\n")
            body.append(image)
            body.appendString("\r\n")
        }
        body.appendString("--\(boundary)--")
        
        return body as Data
    }
    
}

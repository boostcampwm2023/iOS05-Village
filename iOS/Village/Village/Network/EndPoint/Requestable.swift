//
//  Requestable.swift
//  Village
//
//  Created by 박동재 on 2023/11/21.
//

import Foundation

protocol Requestable {
    
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: Encodable? { get }
    var bodyParameters: PostCreateInfo? { get }
    var headers: [String: String]? { get }
    
}

extension Requestable {
    
    func makeURLRequest() throws -> URLRequest {
        let url = try makeURL()
        
        //        if let bodyParameters = try bodyParameters?.toDictionary() {
        //            if !bodyParameters.isEmpty {
        //                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters)
        //            }
        //        }
        
        let boundary = "----WebKitFormBoundary\(UUID().uuidString)"
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type") // header
        
        let httpBody = NSMutableData()
        
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"post_info\"\r\n"
        fieldString += "\r\n"
        
        if let postInfo = try bodyParameters?.postInfo.toDictionary() {
            if !postInfo.isEmpty,
               let postInfoValue = try? JSONSerialization.data(withJSONObject: postInfo),
               let string = String(data: postInfoValue, encoding: .utf8) {
                fieldString += "\(string)\r\n"
            }
        }
        
        httpBody.appendString(fieldString)
        httpBody.append(convertImage(images: bodyParameters?.images ?? [], boundary: boundary))
        httpBody.appendString("--\(boundary)--")
        print("\n\n")
        print(String(data: httpBody as Data, encoding: .utf8))
        print("\n\n")
        urlRequest.httpBody = httpBody as Data
        headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        dump(urlRequest.allHTTPHeaderFields)
        
        return urlRequest
    }
    
    func makeURL() throws -> URL {
        let fullPath = baseURL + path
        guard var urlComponents = URLComponents(string: fullPath) else { throw NetworkError.componentsError }
        
        var urlQueryItems = [URLQueryItem]()
        if let queryParameters = try queryParameters?.toDictionary() {
            queryParameters.forEach {
                urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
            }
        }
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        
        guard let url = urlComponents.url else { throw NetworkError.componentsError}
        return url
    }
    
    func convertImage(images: [ImageDTO], boundary: String) -> Data {
        let data = NSMutableData()
        
        images.forEach { image in
            data.appendString("--\(boundary)\r\n")
            data.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"\(image.fileName)\"\r\n")
            data.appendString("Content-Type: \(image.type)\r\n\r\n")
            data.append(image.data)
            data.appendString("\r\n")
        }
        return data as Data
    }
    
}

extension Encodable {
    
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        dump(jsonData)
        return jsonData as? [String: Any]
    }
    
}

extension NSMutableData {
    
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
    
}

struct FileDTO {
    
    let fieldName: String
    let fileName: String
    let mimeType: String
    let fileData: Data
    
}

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
    var bodyParameters: Encodable? { get }
    var headers: [String: String]? { get }
    
}

extension Requestable {
    
    func makeURLRequest() throws -> URLRequest {
        let url = try makeURL()
        var urlRequest = URLRequest(url: url)
        
        do {
            if let bodyParameters = try bodyParameters?.toDictionary() {
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters)
            }
        } catch {
            urlRequest.httpBody = bodyParameters as? Data
        }
        
        urlRequest.httpMethod = method.rawValue
        
        headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        return urlRequest
    }
    
    func makeURL() throws -> URL {
        let fullPath = baseURL + path
        guard var urlComponents = URLComponents(string: fullPath) else { throw NetworkError.componentsError }
        
        if let queryParameters {
            guard let parameters = try queryParameters.toDictionary(),
                  !parameters.isEmpty else { throw NetworkError.queryParameterError }
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        
        guard let url = urlComponents.url else { throw NetworkError.componentsError }
        
        return url
    }
    
}

//
//  EndPoint.swift
//  Village
//
//  Created by 박동재 on 2023/11/21.
//

import Foundation

final class EndPoint<R>: Requestable, Responsable {
    
    typealias Response = R
    
    var baseURL: String
    var path: String
    var method: HTTPMethod
    var queryParameters: Encodable?
    var bodyParameters: Encodable?
    var headers: [String: String]?

    init(baseURL: String,
         path: String = "",
         method: HTTPMethod = .GET,
         queryParameters: Encodable? = nil,
         bodyParameters: Encodable? = nil,
         headers: [String: String]? = [:]) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.bodyParameters = bodyParameters
        self.headers = headers
    }
    
}

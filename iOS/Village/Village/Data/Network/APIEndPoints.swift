//
//  APIEndPoints.swift
//  Village
//
//  Created by 박동재 on 2023/11/22.
//

import Foundation

struct APIEndPoints {
    
    static func getPosts(with postResponse: PostRequestDTO) -> EndPoint<[PostResponseDTO]> {
        return EndPoint(
            baseURL: "http://118.67.130.107:3000/",
            path: "posts",
            method: .GET,
            queryParameters: postResponse
        )
    }
    
    static func getData(with url: String) -> EndPoint<Data> {
        return EndPoint(baseURL: url)
    }
    
    static func getOnban(with request: TestRequestDTO) -> EndPoint<Onban> {
        return EndPoint(
            baseURL: "https://api.codesquad.kr/onban/",
            path: "main",
            method: .GET,
            queryParameters: request
        )
    }
}
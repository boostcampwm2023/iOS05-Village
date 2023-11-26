//
//  APIEndPoints.swift
//  Village
//
//  Created by 박동재 on 2023/11/22.
//

import Foundation

struct APIEndPoints {
    
    static func getPosts(with postResponse: PostListRequestDTO) -> EndPoint<[PostListResponseDTO]> {
        return EndPoint(
            baseURL: "http://118.67.130.107:3000/",
            path: "posts",
            method: .GET,
            queryParameters: postResponse
        )
    }
    
    static func getPost(id: Int) -> EndPoint<PostResponseDTO> {
        return EndPoint(
            baseURL: "http://118.67.130.107:3000/",
            path: "posts/\(id)",
            method: .GET
        )
    }
    
    static func getUser(id: String) -> EndPoint<UserResponseDTO> {
        return EndPoint(
            baseURL: "http://118.67.130.107:3000/",
            path: "users/\(id)",
            method: .GET
        )
    }
    
    static func getData(with url: String) -> EndPoint<Data> {
        return EndPoint(baseURL: url)
    }
    
    static func getChatList(with chatListResponse: ChatListRequestDTO) -> EndPoint<[ChatListResponseDTO]> {
        return EndPoint(
            baseURL: "http://118.67.130.107:3000/",
            path: "chat",
            method: .GET,
            queryParameters: chatListResponse
        )
    }
}

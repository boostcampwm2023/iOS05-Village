//
//  APIEndPoints.swift
//  Village
//
//  Created by 박동재 on 2023/11/22.
//

import Foundation

struct APIEndPoints {
    
    static let baseURL = "https://www.village-api.shop/"
    
    static func getPosts(with requestDTO: PostListRequestDTO) -> EndPoint<[PostListResponseDTO]> {
        return EndPoint(
            baseURL: baseURL,
            path: "posts",
            method: .GET,
            queryParameters: requestDTO
        )
    }
    
    static func getPost(id: Int) -> EndPoint<PostResponseDTO> {
        return EndPoint(
            baseURL: baseURL,
            path: "posts/\(id)",
            method: .GET
        )
    }
    
    static func getUser(id: String) -> EndPoint<UserResponseDTO> {
        return EndPoint(
            baseURL: baseURL,
            path: "users/\(id)",
            method: .GET
        )
    }
    
    static func createPost(with requestDTO: PostCreateRequestDTO) -> EndPoint<Void> {
        return EndPoint(
            baseURL: baseURL,
            path: "posts",
            method: .POST,
            bodyParameters: requestDTO.httpBody,
            headers: ["Content-Type": "multipart/form-data; boundary=\(requestDTO.boundary)"]
        )
    }
    
    static func getChatList(with chatListResponse: ChatListRequestDTO) -> EndPoint<[ChatListResponseDTO]> {
        return EndPoint(
            baseURL: baseURL,
            path: "chat",
            method: .GET,
            queryParameters: chatListResponse
        )
    }
    
    static func loginAppleOAuth(with appleOAuthDTO: AppleOAuthDTO) -> EndPoint<AuthenticationToken> {
        EndPoint(
            baseURL: baseURL,
            path: "login/appleOAuth",
            method: .POST,
            bodyParameters: appleOAuthDTO,
            headers: ["Content-Type": "application/json"]
        )
    }
    
    static func tokenExpire(accessToken: String) -> EndPoint<Void> {
        EndPoint(
            baseURL: baseURL,
            path: "login/expire",
            method: .GET
        )
    }
    
    static func tokenRefresh(refreshToken: String) -> EndPoint<AuthenticationToken> {
        let body = ["refresh_token": refreshToken]
        
        return EndPoint(
            baseURL: baseURL,
            path: "login/refresh",
            method: .POST,
            bodyParameters: body,
            headers: ["Content-Type": "application/json"]
        )
    }
  
}

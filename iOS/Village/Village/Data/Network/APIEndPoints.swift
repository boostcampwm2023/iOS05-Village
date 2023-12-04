//
//  APIEndPoints.swift
//  Village
//
//  Created by 박동재 on 2023/11/22.
//

import Foundation

struct APIEndPoints {
    
    static let baseURL = "https://www.village-api.shop/"
    
    static var header: [String: String]? {
        guard let accessToken = JWTManager.shared.get()?.accessToken else { return nil }
        
        return ["Authorization": "Bearer \(accessToken)"]
    }
    
    static func getPosts(with requestDTO: PostListRequestDTO) -> EndPoint<[PostListResponseDTO]> {
        return EndPoint(
            baseURL: baseURL,
            path: "posts",
            method: .GET,
            queryParameters: requestDTO,
            headers: header
        )
    }
    
    static func getPost(id: Int) -> EndPoint<PostResponseDTO> {
        return EndPoint(
            baseURL: baseURL,
            path: "posts/\(id)",
            method: .GET,
            headers: header
        )
    }
    
    static func getUser(id: String) -> EndPoint<UserResponseDTO> {
        return EndPoint(
            baseURL: baseURL,
            path: "users/\(id)",
            method: .GET,
            headers: header
        )
    }
    
    static func createPost(with requestDTO: PostCreateRequestDTO) -> EndPoint<Void> {
        return EndPoint(
            baseURL: baseURL,
            path: "posts",
            method: .POST,
            bodyParameters: requestDTO.httpBody,
            headers: header?.mergeWith(["Content-Type": "multipart/form-data; boundary=\(requestDTO.boundary)"])
        )
    }
    
    static func getChatList(with chatListResponse: ChatListRequestDTO) -> EndPoint<[ChatListResponseDTO]> {
        return EndPoint(
            baseURL: baseURL,
            path: "chat",
            method: .GET,
            queryParameters: chatListResponse,
            headers: header
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
            method: .GET,
            headers: header
        )
    }
    
    static func tokenRefresh(refreshToken: String) -> EndPoint<AuthenticationToken> {
        let body = ["refresh_token": refreshToken]
        
        return EndPoint(
            baseURL: baseURL,
            path: "login/refresh",
            method: .POST,
            bodyParameters: body,
            headers: header?.mergeWith(["Content-Type": "application/json"])
        )
    }
    
    static func fcmTokenSend(fcmToken: String) -> EndPoint<String> {
        return EndPoint(
            baseURL: baseURL,
            path: "users/registration-token",
            method: .POST,
            bodyParameters: ["registration_token": fcmToken],
            headers: header?.mergeWith(["Content-Type": "application/json"])
        )
    }
  
}

fileprivate extension Dictionary<String, String> {
    func mergeWith(_ dict: [String: String]) -> [String: String]? {
        return self.merging(dict) { (current, _) in current }
    }
}

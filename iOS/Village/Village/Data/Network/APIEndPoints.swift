//
//  APIEndPoints.swift
//  Village
//
//  Created by 박동재 on 2023/11/22.
//

import Foundation

struct APIEndPoints {
    
    static let baseURL = "https://www.village-api.shop/"
    
    static func getPosts() -> EndPoint<[PostListResponseDTO]> {
        return EndPoint(
            baseURL: baseURL,
            path: "posts",
            method: .GET
        )
    }
    
    static func getPosts(queryParameter: PostListRequestDTO? = nil) -> EndPoint<[PostListResponseDTO]> {
        return EndPoint(
            baseURL: baseURL,
            path: "posts",
            method: .GET,
            queryParameters: queryParameter
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
    
    static func modifyPost(with requestDTO: PostModifyRequestDTO) -> EndPoint<Void> {
        
        var path = "posts"
        var method = HTTPMethod.POST
        if let id = requestDTO.postID {
            path += "/\(id)"
            method = .PATCH
        }
        
        return EndPoint(
            baseURL: baseURL,
            path: path,
            method: method,
            bodyParameters: requestDTO.httpBody,
            headers: ["Content-Type": "multipart/form-data; boundary=\(requestDTO.boundary)"]
        )
    }
    
    static func editPost(with requestDTO: PostModifyRequestDTO, postID: Int) -> EndPoint<Void> {
        return EndPoint(
            baseURL: baseURL,
            path: "posts/\(postID)",
            method: .PATCH,
            bodyParameters: requestDTO.httpBody,
            headers: ["Content-Type": "multipart/form-data; boundary=\(requestDTO.boundary)"]
        )
    }
    
    static func deletePost(with postID: Int) -> EndPoint<Void> {
        return EndPoint(
            baseURL: baseURL,
            path: "posts/\(postID)",
            method: .DELETE
        )
    }
    
    static func getChatList() -> EndPoint<[GetChatListResponseDTO]> {
        return EndPoint(
            baseURL: baseURL,
            path: "chat/room",
            method: .GET
        )
    }
    
    static func deleteChatRoom(with chatRoomRequest: ChatRoomRequestDTO) -> EndPoint<Void> {
        return EndPoint(
            baseURL: baseURL,
            path: "chat",
            method: .DELETE,
            queryParameters: chatRoomRequest
        )
    }
    
    static func postCreateChatRoom(with postRoomRequest: PostRoomRequestDTO) -> EndPoint<PostRoomResponseDTO> {
        return EndPoint(
            baseURL: baseURL,
            path: "chat/room",
            method: .POST,
            bodyParameters: postRoomRequest,
            headers: [
                "Content-Type": "application/json",
                "accept": "application/json"
            ]
        )
    }
    
    static func getChatRoom(with roomID: Int) -> EndPoint<GetRoomResponseDTO> {
        return EndPoint(
            baseURL: baseURL,
            path: "chat/room/\(roomID)",
            method: .GET
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
    
    static func fcmTokenSend(fcmToken: String) -> EndPoint<String> {
        return EndPoint(
            baseURL: baseURL,
            path: "users/registration-token",
            method: .POST,
            bodyParameters: ["registration_token": fcmToken],
            headers: ["Content-Type": "application/json"]
        )
    }
    
    static func userDelete(userID: String) -> EndPoint<Void> {
        EndPoint(
            baseURL: baseURL,
            path: "users/\(userID)",
            method: .DELETE
        )
    }
    
    static func logout() -> EndPoint<Void> {
        EndPoint(
            baseURL: baseURL,
            path: "logout",
            method: .POST
        )
    }
    
    static func patchUser(userInfo: PatchUserDTO) -> EndPoint<Void> {
        return EndPoint(
            baseURL: baseURL,
            path: "users/\(userInfo.userID)",
            method: .PATCH,
            bodyParameters: userInfo.httpBody,
            headers: ["Content-Type": "multipart/form-data; boundary=\(userInfo.boundary)"]
        )
    }
    
}

//
//  ChatRoomViewModel.swift
//  Village
//
//  Created by 박동재 on 2023/11/26.
//

import Foundation
import Combine

struct Message: Hashable, Codable {
    
    let roomID: Int
    let sender: String
    let message: String
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case sender
        case message
        case count
    }
    
}

struct ChatRoomResponseDTO: Hashable, Codable {
    
    let user: String
    let chatLog: [Message]
    let postImage: String
    let postName: String
    let postPrice: String
    let postIsRequest: Bool
    let postID: Int
    
    enum CodingKeys: String, CodingKey {
        case user
        case chatLog = "chat_log"
        case postImage = "post_image"
        case postName = "post_name"
        case postPrice = "post_price"
        case postIsRequest = "post_is_request"
        case postID = "post_id"
    }
    
    init(dto: ChatRoomResponseDTO) {
        self.user = dto.user
        self.chatLog = dto.chatLog
        self.postImage = dto.postImage
        self.postName = dto.postName
        self.postPrice = dto.postPrice
        self.postIsRequest = dto.postIsRequest
        self.postID = dto.postID
    }
    
}

final class ChatRoomViewModel {
    
    private var chatRoom = PassthroughSubject<GetRoomResponseDTO, NetworkError>()
    private var post = PassthroughSubject<PostResponseDTO, NetworkError>()
    private var cancellableBag = Set<AnyCancellable>()
    private var chatLog: [Message] = []
    
    private var test: ChatRoomResponseDTO?
    
    func transformRoom(input: RoomInput) -> RoomOutput {
        input.roomID
            .sink(receiveValue: { [weak self] id in
                self?.getChatRoomData(id: id)
            })
            .store(in: &cancellableBag)
        
        return RoomOutput(chatRoom: chatRoom.eraseToAnyPublisher())
    }
    
    func transformPost(input: PostInput) -> PostOutput {
        input.postID
            .sink(receiveValue: { [weak self] id in
                self?.getPost(id: id)
            })
            .store(in: &cancellableBag)
        
        return PostOutput(post: post.eraseToAnyPublisher())
    }
    
    func getChatRoomData(id: Int) {
        let endpoint = APIEndPoints.getChatRoom(with: id)
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                data.chatLog.forEach { chat in
                    self.chatLog.append(
                        Message(roomID: 164, sender: chat.sender, message: chat.message, count: chat.id)
                    )
                    // roomID 추가예정, id -> count로 변경예정
                }
                chatRoom.send(data)
            } catch let error as NetworkError {
                chatRoom.send(completion: .failure(error))
            }
        }
    }
    
    func getPost(id: Int) {
        let endpoint = APIEndPoints.getPost(id: id)
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                post.send(data)
                dump(data)
            } catch let error as NetworkError {
                post.send(completion: .failure(error))
            }
        }
    }
    
    func getLog() -> [Message]? {
        return chatLog
    }
    
    func appendLog(sender: String, message: String) {
        chatLog.append(Message(roomID: 164, sender: sender, message: message, count: chatLog.count))
    }
    
    func getTest() -> ChatRoomResponseDTO? {
        return test
    }
    
}

extension ChatRoomViewModel {
    
    struct RoomInput {
        var roomID: AnyPublisher<Int, Never>
    }
    
    struct RoomOutput {
        var chatRoom: AnyPublisher<GetRoomResponseDTO, NetworkError>
    }
    
    struct PostInput {
        var postID: AnyPublisher<Int, Never>
    }
    
    struct PostOutput {
        var post: AnyPublisher<PostResponseDTO, NetworkError>
    }
    
}

//
//  ChatRoomViewModel.swift
//  Village
//
//  Created by 박동재 on 2023/11/26.
//

import Foundation
import Combine

struct Message: Hashable, Codable {
    
    let sender: String
    let message: String
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case sender
        case message
        case count
    }
    
}

final class ChatRoomViewModel {
    
    private var chatRoom = PassthroughSubject<GetRoomResponseDTO, NetworkError>()
    private var post = PassthroughSubject<PostResponseDTO, NetworkError>()
    private var cancellableBag = Set<AnyCancellable>()
    private var chatLog: [Message] = []
    
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
            } catch let error as NetworkError {
                post.send(completion: .failure(error))
            }
        }
    }
    
    func appendLog(sender: String, message: String) {
        chatLog.append(Message(sender: sender, message: message, count: chatLog.count))
    }
    
    func getLog() -> [Message] {
        return chatLog
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

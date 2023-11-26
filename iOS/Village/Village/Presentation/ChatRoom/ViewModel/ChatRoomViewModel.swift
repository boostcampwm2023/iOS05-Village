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
    let body: String
    
    enum CodingKeys: String, CodingKey {
        case sender
        case body
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
    
    private var chatRoom = PassthroughSubject<ChatRoomResponseDTO, NetworkError>()
    private var cancellableBag = Set<AnyCancellable>()
    
    func transform(input: Input) -> Output {
        input.roomID
            .sink(receiveValue: { [weak self] id in
                self?.getRoom(id: id)
            })
            .store(in: &cancellableBag)
        
        return Output(chatRoom: chatRoom.eraseToAnyPublisher())
    }
    
    func getRoom(id: Int) {
//        let endpoint = APIEndPoints.getRoom(id: id)
//        
//        Task {
//            do {
//                let data = try await Provider.shared.request(with: endpoint)
//                chatRoom.send(data)
//            } catch let error as NetworkError {
//                chatRoom.send(completion: .failure(error))
//            }
//        }
        guard let path = Bundle.main.path(forResource: "ChatRoom", ofType: "json") else { return }
        
        guard let jsonString = try? String(contentsOfFile: path) else { return }
        do {
            let decoder = JSONDecoder()
            let data = jsonString.data(using: .utf8)
            
            guard let data = data else { return }
            let room = try decoder.decode(ChatRoomResponseDTO.self, from: data)
            print(room)
            chatRoom.send(room)
        } catch {
            dump(error)
        }
    }
    
}

extension ChatRoomViewModel {
    
    struct Input {
        var roomID: AnyPublisher<Int, Never>
    }
    
    struct Output {
        var chatRoom: AnyPublisher<ChatRoomResponseDTO, NetworkError>
    }
    
}

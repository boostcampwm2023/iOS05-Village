//
//  ChatListViewModel.swift
//  Village
//
//  Created by 박동재 on 2023/11/24.
//

import Foundation
import Combine

struct ChatListResponseDTO: Hashable, Codable {

    let user: String
    let userProfile: String?
    let recentTime: String
    let recentChat: String
    let postImage: String?

    enum CodingKeys: String, CodingKey {
        case user
        case userProfile = "user_profile"
        case recentTime = "recent_time"
        case recentChat = "recent_chat"
        case postImage = "post_image"
    }
    
    init(dto: ChatListResponseDTO) {
        self.user = dto.user
        self.userProfile = dto.userProfile
        self.recentTime = dto.recentTime
        self.recentChat = dto.recentChat
        self.postImage = dto.postImage
    }
    
}

struct ChatListRequestDTO: Codable {
    
    let page: Int
    
    enum CodingKeys: String, CodingKey {
        case page
    }
    
}

final class ChatListViewModel {
    
    private var cancellableBag = Set<AnyCancellable>()
    private var chatList = PassthroughSubject<[GetChatListResponseDTO], NetworkError>()
    
    private var test: [ChatListResponseDTO] = []
    
    func transform(input: Input) -> Output {
        input.getChatListSubject
            .sink(receiveValue: { [weak self] () in
                self?.getChatList()
            })
            .store(in: &cancellableBag)
        
        return Output(chatList: chatList.eraseToAnyPublisher())
    }
    
    private func getChatList() {
        let endpoint = APIEndPoints.getChatList()
        
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                chatList.send(data)
            } catch let error as NetworkError {
                chatList.send(completion: .failure(error))
            }
        }
    }
    
    func deleteChatRoom(roomID: Int) {
        let request = ChatRoomRequestDTO(roomID: roomID)
        let endpoint = APIEndPoints.deleteChatRoom(with: request)
        
        Task {
            do {
                try await APIProvider.shared.request(with: endpoint)
            } catch {
                dump(error)
            }
        }
    }
    
    func updateTest(list: [ChatListResponseDTO]) {
        test = list
    }
    
    func getTest() -> [ChatListResponseDTO] {
        return test
    }

}

extension ChatListViewModel {
    
    struct Input {
        var getChatListSubject: AnyPublisher<Void, Never>
    }
    
    struct Output {
        var chatList: AnyPublisher<[GetChatListResponseDTO], NetworkError>
    }
    
}

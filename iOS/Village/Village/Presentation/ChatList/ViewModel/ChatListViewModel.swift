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
    private var chatList = PassthroughSubject<[ChatListResponseDTO], Never>()
    
    func transform(input: Input) -> Output {
        input.currentPage
            .sink(receiveValue: { [weak self] page in
                self?.getChatList(page: page)
            })
            .store(in: &cancellableBag)
        
        return Output(chatList: chatList.eraseToAnyPublisher())
    }
    
    private func getChatList(page: Int) {
        let request = ChatListRequestDTO(page: page)
        let endpoint = APIEndPoints.getChatList(with: request)
        
        Task {
            do {
                let data = try await Provider.shared.request(with: endpoint)
                chatList.send(data.map { ChatListResponseDTO(dto: $0) })
            } catch let error {
                dump(error)
            }
        }
    }

}

extension ChatListViewModel {
    
    struct Input {
        var currentPage: CurrentValueSubject<Int, Never>
    }
    
    struct Output {
        var chatList: AnyPublisher<[ChatListResponseDTO], Never>
    }
    
}

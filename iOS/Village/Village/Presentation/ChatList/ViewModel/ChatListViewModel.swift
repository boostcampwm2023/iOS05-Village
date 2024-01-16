//
//  ChatListViewModel.swift
//  Village
//
//  Created by 박동재 on 2023/11/24.
//

import Foundation
import Combine

final class ChatListViewModel {
    
    private var cancellableBag = Set<AnyCancellable>()
    private let chatList = PassthroughSubject<ChatList, NetworkError>()
    private var roomIDList: [Int] = []
    
    func transform(input: Input) -> Output {
        input.getChatListSubject
            .sink(receiveValue: { [weak self] () in
                self?.getList()
            })
            .store(in: &cancellableBag)
        
        return Output(chatList: chatList.eraseToAnyPublisher())
    }
    
    private func getList() {
        ChatListUseCase(
            repository: DefaultChatListRepository()
        )
        .start()
        .sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                dump(error)
            }
        } receiveValue: { [weak self] list in
            self?.chatList.send(list)
            self?.roomIDList.removeAll()
            list.chatList.forEach { item in
                self?.roomIDList.append(item.roomID)
            }
        }
        .store(in: &cancellableBag)

    }
    
    func deleteChatRoom(index: Int) {
        DeleteChatUseCase(
            repository: DefaultDeleteChatRepository(),
            roomID: self.roomIDList[index]
        ).start().sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                dump(error)
            }
        } receiveValue: {}
        .store(in: &cancellableBag)
    }
    
}

extension ChatListViewModel {
    
    struct Input {
        let getChatListSubject: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let chatList: AnyPublisher<ChatList, NetworkError>
    }
    
}

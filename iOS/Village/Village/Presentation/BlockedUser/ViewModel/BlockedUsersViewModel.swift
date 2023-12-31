//
//  BlockedUsersViewModel.swift
//  Village
//
//  Created by 조성민 on 12/10/23.
//

import Foundation
import Combine

struct BlockUserInfo {
    
    let userID: String
    let isBlocked: Bool
    
}

final class BlockedUsersViewModel {
    
    private let blockedUsers = CurrentValueSubject<[BlockedUserDTO], Never>([])
    
    private let blockToggleOutput = PassthroughSubject<Bool, Never>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    func transform(input: Input) -> Output {
        
        input.blockedToggleInput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userInfo in
                self?.toggleBlock(
                    userID: userInfo.userID,
                    isBlocked: userInfo.isBlocked
                )
            }
            .store(in: &cancellableBag)
        
        return Output(
            blockedUsersOutput: blockedUsers.eraseToAnyPublisher()
        )
    }
    
    init() {
        getMyBlockedUsers()
    }
    
    deinit {
        PostNotificationPublisher.shared.publishPostRefreshAll()
    }
    
    private func getMyBlockedUsers() {
        let endpoint = APIEndPoints.getBlockedUsers()
        
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                blockedUsers.send(data)
            } catch {
                dump(error)
            }
        }
    }
    
    private func toggleBlock(userID: String, isBlocked: Bool) {
        let endpoint = isBlocked ?
        APIEndPoints.blockUser(userID: userID) :
        APIEndPoints.unblockUser(userID: userID)
        
        Task {
            do {
                try await APIProvider.shared.request(with: endpoint)
            } catch {
                dump(error)
            }
        }
    }
    
}

extension BlockedUsersViewModel {
    
    struct Input {
        let blockedToggleInput: AnyPublisher<BlockUserInfo, Never>
    }
    
    struct Output {
        let blockedUsersOutput: AnyPublisher<[BlockedUserDTO], Never>
    }
    
}

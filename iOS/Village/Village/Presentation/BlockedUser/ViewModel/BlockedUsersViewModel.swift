//
//  BlockedUsersViewModel.swift
//  Village
//
//  Created by 조성민 on 12/10/23.
//

import Foundation
import Combine

final class BlockedUsersViewModel {
    
    private let blockedUsers = CurrentValueSubject<[BlockedUserDTO], Never>([])
    
    private let blockToggleOutput = PassthroughSubject<Bool, Never>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    func transform(input: Input) -> Output {
        
        return Output(
            blockedUsersOutput: blockedUsers.eraseToAnyPublisher()
        )
    }
    
    init() {
        getMyBlockedUsers()
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
    
}

extension BlockedUsersViewModel {
    
    struct Input {
    }
    
    struct Output {
        let blockedUsersOutput: AnyPublisher<[BlockedUserDTO], Never>
    }
    
}

//
//  MyPageViewModel.swift
//  Village
//
//  Created by 조성민 on 11/30/23.
//

import Foundation
import Combine

final class MyPageViewModel {
    
    private var cancellableBag = Set<AnyCancellable>()
    private var logoutSucceed = PassthroughSubject<Void, Error>()
    private var deleteAccountSucceed = PassthroughSubject<Void, Error>()
    private var nicknameSubject = CurrentValueSubject<String, Never>("")
    private var profileImageDataSubject = CurrentValueSubject<Data?, Never>(nil)
    
    init() {
        getUserInfo()
    }
    
    private func getUserInfo() {
        guard let userID = JWTManager.shared.currentUserID else { return }
        let endpoint = APIEndPoints.getUser(id: userID)
        
        Task {
            do {
                guard let userData = try await APIProvider.shared.request(with: endpoint) else { return }
                nicknameSubject.send(userData.nickname)
                let userImageData = try await APIProvider.shared.request(from: userData.profileImageURL)
                profileImageDataSubject.send(userImageData)
            } catch let error as NetworkError {
                dump(error)
            } catch {
                dump(error)
            }
        }
    }
    
    
    
    func transform(input: Input) -> Output {
        input.logoutSubject
            .sink(receiveValue: { [weak self] in
                self?.logout()
            })
            .store(in: &cancellableBag)
        
        input.deleteAccountSubject
            .sink(receiveValue: { [weak self] in
                self?.deleteAccount()
            })
            .store(in: &cancellableBag)
        
        return Output(
            logoutSucceed: logoutSucceed.eraseToAnyPublisher(),
            deleteAccountSucceed: deleteAccountSucceed.eraseToAnyPublisher(),
            nicknameOutput: nicknameSubject.eraseToAnyPublisher(),
            profileImageDataOutput: profileImageDataSubject.eraseToAnyPublisher()
        )
    }
    
    private func logout() {
        let endpoint = APIEndPoints.logout()
        
        Task {
            do {
                try await APIProvider.shared.request(with: endpoint)
                try JWTManager.shared.delete()
                deleteAccountSucceed.send()
            } catch {
                deleteAccountSucceed.send(completion: .failure(error))
            }
        }
    }
    
    private func deleteAccount() {
        guard let userID = JWTManager.shared.currentUserID else { return }
        
        let endpoint = APIEndPoints.userDelete(userID: userID)
        Task {
            do {
                try await APIProvider.shared.request(with: endpoint)
                try JWTManager.shared.delete()
                deleteAccountSucceed.send()
            } catch {
                deleteAccountSucceed.send(completion: .failure(error))
            }
        }
    }
    
}

extension MyPageViewModel {
    
    struct Input {
        var logoutSubject: AnyPublisher<Void, Never>
        var deleteAccountSubject: AnyPublisher<Void, Never>
    }
    
    struct Output {
        var logoutSucceed: AnyPublisher<Void, Error>
        var deleteAccountSucceed: AnyPublisher<Void, Error>
        var nicknameOutput: AnyPublisher<String, Never>
        var profileImageDataOutput: AnyPublisher<Data?, Never>
    }
    
}

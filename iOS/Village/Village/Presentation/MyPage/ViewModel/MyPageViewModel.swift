//
//  MyPageViewModel.swift
//  Village
//
//  Created by 조성민 on 11/30/23.
//

import Foundation
import Combine

struct ProfileInfo {
    
    var nickname: String
    var profileImage: Data?
    
}

final class MyPageViewModel {
    
    private var cancellableBag = Set<AnyCancellable>()
    private var logoutSucceed = PassthroughSubject<Void, Error>()
    private var deleteAccountSucceed = PassthroughSubject<Void, Error>()
    
    var profileInfoSubject = CurrentValueSubject<ProfileInfo?, Never>(nil)
    
    init() {
        getUserInfo()
    }
    
    func getUserInfo() {
        guard let userID = JWTManager.shared.currentUserID else { return }
        let endpoint = APIEndPoints.getUser(id: userID)
        
        Task {
            do {
                guard let userData = try await APIProvider.shared.request(with: endpoint) else { return }
                let userImageData = try await APIProvider.shared.request(from: userData.profileImageURL)
                profileInfoSubject.send(ProfileInfo(
                    nickname: userData.nickname,
                    profileImage: userImageData
                ))
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
            profileInfoOutput: profileInfoSubject.eraseToAnyPublisher()
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
        var profileInfoOutput: AnyPublisher<ProfileInfo?, Never>
    }
    
}

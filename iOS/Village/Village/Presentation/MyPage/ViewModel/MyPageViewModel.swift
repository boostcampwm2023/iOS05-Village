//
//  MyPageViewModel.swift
//  Village
//
//  Created by 조성민 on 11/30/23.
//

import Foundation
import Combine

struct ProfileInfo: Equatable {
    
    var nickname: String
    var profileImage: Data?
    
}

final class MyPageViewModel {
    
    private var cancellableBag = Set<AnyCancellable>()
    private let logoutSucceed = PassthroughSubject<Void, Error>()
    private let deleteAccountSucceed = PassthroughSubject<Void, Error>()
    private let profileInfoSubject = PassthroughSubject<ProfileInfo, Never>()
    private let editProfileInfoSubject = PassthroughSubject<ProfileInfo, Never>()
    private let refreshInput = PassthroughSubject<Void, Never>()
    
    private func getUserInfo() {
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
        
        input.editProfileSubject
            .sink { [weak self] _ in
                self?.editProfile()
            }
            .store(in: &cancellableBag)
        
        input.refreshInputSubject
            .sink { [weak self] _ in
                self?.getUserInfo()
            }
            .store(in: &cancellableBag)
        
        return Output(
            logoutSucceed: logoutSucceed.eraseToAnyPublisher(),
            deleteAccountSucceed: deleteAccountSucceed.eraseToAnyPublisher(),
            profileInfoOutput: profileInfoSubject.eraseToAnyPublisher(),
            editProfileOutput: editProfileInfoSubject.eraseToAnyPublisher()
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
    
    private func editProfile() {
        guard let userID = JWTManager.shared.currentUserID else { return }
        
        let endpoint = APIEndPoints.getUser(id: userID)
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                let userImageData = try await APIProvider.shared.request(from: data.profileImageURL)
                editProfileInfoSubject.send(
                    ProfileInfo(
                        nickname: data.nickname,
                        profileImage: userImageData
                    )
                )
            } catch {
                dump(error)
            }
        }
    }
    
}

extension MyPageViewModel {
    
    struct Input {
        let logoutSubject: AnyPublisher<Void, Never>
        let deleteAccountSubject: AnyPublisher<Void, Never>
        let editProfileSubject: AnyPublisher<Void, Never>
        let refreshInputSubject: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let logoutSucceed: AnyPublisher<Void, Error>
        let deleteAccountSucceed: AnyPublisher<Void, Error>
        let profileInfoOutput: AnyPublisher<ProfileInfo, Never>
        let editProfileOutput: AnyPublisher<ProfileInfo, Never>
    }
    
}

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
    
    private let tableViewSectionContents = [
        [""],
        ["내 게시글", "숨긴 게시글", "차단 관리"],
        ["로그아웃", "회원 탈퇴"]
    ]
    private var profileInfo: ProfileInfo?
    
    private var cancellableBag = Set<AnyCancellable>()
    private let logoutSucceed = PassthroughSubject<Void, Error>()
    private let deleteAccountSucceed = PassthroughSubject<Void, Error>()
    private let profileInfoSubject = PassthroughSubject<ProfileInfo, Never>()
    private let editProfileInfoSubject = PassthroughSubject<ProfileInfo, Never>()
    private let refreshOutput = PassthroughSubject<Void, Never>()
    
    private func getUserInfo() {
        guard let userID = JWTManager.shared.currentUserID else { return }
        let endpoint = APIEndPoints.getUser(id: userID)
        
        Task {
            do {
                guard let userData = try await APIProvider.shared.request(with: endpoint) else { return }
                let userImageData = try await APIProvider.shared.request(from: userData.profileImageURL)
                self.profileInfo = ProfileInfo(
                    nickname: userData.nickname,
                    profileImage: userImageData
                )
                self.refreshOutput.send()
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
            editProfileOutput: editProfileInfoSubject.eraseToAnyPublisher(),
            refreshOutput: refreshOutput.eraseToAnyPublisher()
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
    
    func getTableViewContent(section: Int, row: Int) -> String {
        return tableViewSectionContents[section][row]
    }
    
    func getTableViewContentCount(section: Int) -> Int {
        tableViewSectionContents[section].count
    }
    
    func getProfileInfo() -> ProfileInfo? {
        return self.profileInfo
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
        let editProfileOutput: AnyPublisher<ProfileInfo, Never>
        let refreshOutput: AnyPublisher<Void, Never>
    }
    
}

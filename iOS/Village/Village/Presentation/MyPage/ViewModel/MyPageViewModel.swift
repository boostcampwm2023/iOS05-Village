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
            deleteAccountSucceed: deleteAccountSucceed.eraseToAnyPublisher()
        )
    }
    
    private func logout() {
        // TODO: 로그아웃 로직 구현
    }
    
    private func deleteAccount() {
        // TODO: 회원탈퇴 로직 구현
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
    }
    
}

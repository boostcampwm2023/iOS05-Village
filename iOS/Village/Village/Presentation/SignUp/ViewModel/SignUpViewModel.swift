//
//  SignUpViewModel.swift
//  Village
//
//  Created by 조성민 on 12/7/23.
//

import Foundation
import Combine

final class SignUpViewModel {
    
    private let previousInfo: ProfileInfo
    private var nowInfo: ProfileInfo
    private let completeButtonOutput = PassthroughSubject<Bool, Never>()
    private var cancellableBag = Set<AnyCancellable>()
    
    init(profileInfo: ProfileInfo) {
        previousInfo = profileInfo
        nowInfo = profileInfo
    }
    
    func transform(input: Input) -> Output {
        input.nicknameInput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.nowInfo.nickname = nickname
                self?.completeButtonOutput.send(self?.nowInfo != self?.previousInfo)
            }
            .store(in: &cancellableBag)
        
        input.profileImageDataInput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profileImageData in
                self?.nowInfo.profileImage = profileImageData
                self?.completeButtonOutput.send(self?.nowInfo != self?.previousInfo)
            }
            .store(in: &cancellableBag)
        
        return Output(
            completeButtonOutput: completeButtonOutput.eraseToAnyPublisher()
        )
    }
    
    func getPreviousInfo() -> ProfileInfo {
        return previousInfo
    }
    
}

extension SignUpViewModel {
    
    struct Input {
        let nicknameInput: PassthroughSubject<String, Never>
        let profileImageDataInput: PassthroughSubject<Data?, Never>
    }
    
    struct Output {
        let completeButtonOutput: AnyPublisher<Bool, Never>
    }
    
}

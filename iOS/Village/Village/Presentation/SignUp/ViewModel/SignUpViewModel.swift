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
    private let completeButtonEnableOutput = PassthroughSubject<Bool, Never>()
    private let completeButtonOutput = PassthroughSubject<Void, Never>()
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
                self?.completeButtonEnableOutput.send(self?.nowInfo != self?.previousInfo)
            }
            .store(in: &cancellableBag)
        
        input.profileImageDataInput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profileImageData in
                self?.nowInfo.profileImage = profileImageData
                self?.completeButtonEnableOutput.send(self?.nowInfo != self?.previousInfo)
            }
            .store(in: &cancellableBag)
        
        input.completeButtonSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateProfile()
            }
            .store(in: &cancellableBag)
        
        return Output(
            completeButtonEnableOutput: completeButtonEnableOutput.eraseToAnyPublisher(),
            completeButtonOutput: completeButtonOutput.eraseToAnyPublisher()
        )
    }
    
    func getPreviousInfo() -> ProfileInfo {
        return previousInfo
    }
    
    func updateProfile() {
        // TODO: completeButtonOutput.send()
    }
    
}

extension SignUpViewModel {
    
    struct Input {
        let nicknameInput: PassthroughSubject<String, Never>
        let profileImageDataInput: PassthroughSubject<Data?, Never>
        let completeButtonSubject: PassthroughSubject<Void, Never>
    }
    
    struct Output {
        let completeButtonEnableOutput: AnyPublisher<Bool, Never>
        let completeButtonOutput: AnyPublisher<Void, Never>
    }
    
}

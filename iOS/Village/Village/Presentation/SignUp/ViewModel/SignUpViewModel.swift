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
    
    private var cancellableBag = Set<AnyCancellable>()
    
    init(profileInfo: ProfileInfo) {
        previousInfo = profileInfo
        nowInfo = profileInfo
    }
    
    func transform(input: Input) -> Output {
        input.nicknameInput
            .receive(on: DispatchQueue.main)
            .sink { nickname in
                self.nowInfo.nickname = nickname
            }
            .store(in: &cancellableBag)
        
        input.profileImageDataInput
            .receive(on: DispatchQueue.main)
            .sink { profileImageData in
                self.nowInfo.profileImage = profileImageData
            }
            .store(in: &cancellableBag)
        
        return Output(
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
    }
    
}

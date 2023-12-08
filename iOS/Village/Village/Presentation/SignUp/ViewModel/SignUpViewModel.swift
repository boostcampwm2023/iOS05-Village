//
//  SignUpViewModel.swift
//  Village
//
//  Created by 조성민 on 12/7/23.
//

import Foundation
import Combine

final class SignUpViewModel {
    
    var profileInfoSubject: CurrentValueSubject<ProfileInfo, Never>
    private let previousInfo: ProfileInfo
    init(profileInfo: ProfileInfo) {
        self.profileInfoSubject = CurrentValueSubject<ProfileInfo, Never>(profileInfo)
        previousInfo = profileInfo
    }
    
    func transform(input: Input) -> Output {
        profileInfoSubject.send(profileInfoSubject.value)
        
        return Output(
            profileInfoOutput: profileInfoSubject.eraseToAnyPublisher()
        )
    }
    
}

extension SignUpViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        let profileInfoOutput: AnyPublisher<ProfileInfo, Never>
    }
    
}

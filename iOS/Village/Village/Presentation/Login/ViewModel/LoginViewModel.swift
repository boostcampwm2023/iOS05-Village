//
//  LoginViewModel.swift
//  Village
//
//  Created by 정상윤 on 11/27/23.
//

import Foundation
import Combine

final class LoginViewModel {
    
    private var cancellableBag = Set<AnyCancellable>()
    private var authenticationToken = PassthroughSubject<AuthenticationToken, Error>()
    
    func transform(input: Input) -> Output {
        Publishers.Zip(input.identityToken, input.authorizationCode)
            .sink(receiveValue: { [weak self] (token, code) in
                guard let tokenString = String(data: token, encoding: .utf8),
                      let codeString = String(data: code, encoding: .utf8) else { return }
                
                self?.handleLoginRequest(dto: AppleOAuthDTO(identityToken: tokenString, authorizationCode: codeString))
            })
            .store(in: &cancellableBag)
        
        return Output(authenticationToken: authenticationToken.eraseToAnyPublisher())
    }
    
    private func handleLoginRequest(dto: AppleOAuthDTO) {
        // TODO: 키체인에 저장된 토큰이 있는지 확인 후 서버 요청하도록 구현
        let endpoint = APIEndPoints.loginAppleOAuth(with: dto)
        Task {
            do {
                guard let responseToken = try await APIProvider.shared.request(with: endpoint) else { return }
                authenticationToken.send(responseToken)
            } catch let error {
                authenticationToken.send(completion: .failure(error))
            }
        }
    }
    
}

extension LoginViewModel {
    
    struct Input {
        var identityToken: AnyPublisher<Data, Never>
        var authorizationCode: AnyPublisher<Data, Never>
    }
    
    struct Output {
        var authenticationToken: AnyPublisher<AuthenticationToken, Error>
    }
    
}

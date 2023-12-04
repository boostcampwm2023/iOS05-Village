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
    private var loginSucceed = PassthroughSubject<Void, Error>()
    
    func transform(input: Input) -> Output {
        Publishers.Zip(input.identityToken, input.authorizationCode)
            .sink(receiveValue: { [weak self] (token, code) in
                guard let tokenString = String(data: token, encoding: .utf8),
                      let codeString = String(data: code, encoding: .utf8),
                      let email = tokenString.decode()["email"] as? String else { return }
                
                let dto = AppleOAuthDTO(identityToken: tokenString, authorizationCode: codeString)
                self?.login(email: email, dto: dto)
            })
            .store(in: &cancellableBag)
        
        return Output(loginSucceed: loginSucceed.eraseToAnyPublisher())
    }
    
    private func login(email: String, dto: AppleOAuthDTO) {
        let endpoint = APIEndPoints.loginAppleOAuth(with: dto)
        Task {
            do {
                guard let token = try await APIProvider.shared.request(with: endpoint) else { return }
                
                JWTManager.shared.save(email: email, token: token)
                loginSucceed.send()
                FCMManager.shared.sendFCMToken()
            } catch let error {
                loginSucceed.send(completion: .failure(error))
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
        var loginSucceed: AnyPublisher<Void, Error>
    }
    
}

fileprivate extension String {
    
    func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
    
    func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
              let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
              let payload = json as? [String: Any] else { return nil }
        return payload
    }
    
    func decode() -> [String: Any] {
        let segments = self.components(separatedBy: ".")
        return decodeJWTPart(segments[1]) ?? [:]
    }
    
}

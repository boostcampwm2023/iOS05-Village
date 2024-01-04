//
//  CombineAuthInterceptor.swift
//  Village
//
//  Created by 조성민 on 1/4/24.
//

import Foundation

protocol CombineInterceptor {
    
    func adapt(request: URLRequest) -> URLRequest?
    func retry(request: URLRequest, error: NetworkError) -> RetryResult
    
}

final class CombineAuthInterceptor: CombineInterceptor {
    
    private let session: URLSession
    private var attempt: Int
    private let maxAttempt: Int
    
    init(session: URLSession = .shared, maxAttempt: Int = 3) {
        self.session = session
        self.attempt = 0
        self.maxAttempt = maxAttempt
    }
    
    func adapt(request: URLRequest) -> URLRequest? {
        guard let accessToken = JWTManager.shared.get()?.accessToken else { return request }
        
        var urlRequest = request
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
    func retry(request: URLRequest, error: NetworkError) -> RetryResult {
        if attempt > maxAttempt {
            attempt = 0
            return .doNotRetry
        }
        attempt += 1
        
        switch error {
        case .serverError(.unauthorized):
            do {
                try refreshToken()
                return .retry
            } catch let error {
                attempt = 0
                NotificationCenter.default.post(name: .shouldLogin, object: nil)
                return .doNotRetryWithError(error)
            }
        default:
            return .retry
        }
    }
    
}

private extension CombineAuthInterceptor {
    
    func refreshToken() throws {
        guard let refreshToken = JWTManager.shared.get()?.refreshToken else { return }
        
        do {
            let request = try APIEndPoints.tokenRefresh(refreshToken: refreshToken).makeURLRequest()
            let result = URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { (data, response) in
                    guard let response = response as? HTTPURLResponse,
                          (200..<300).contains(response.statusCode) else {
                        throw NetworkError.refreshTokenExpired
                    }
                    let newToken = try JSONDecoder().decode(AuthenticationToken.self, from: data)
                    try JWTManager.shared.update(token: newToken)
                }
                .mapError { error in
                    guard let networkError = error as? NetworkError else {
                        return NetworkError.unknownError
                    }
                    return networkError
                }
                .eraseToAnyPublisher()
                
        } catch {
            throw error
        }
    }
    
}

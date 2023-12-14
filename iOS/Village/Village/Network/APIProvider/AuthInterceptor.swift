//
//  AuthInterceptor.swift
//  Village
//
//  Created by 정상윤 on 12/4/23.
//

import Foundation

protocol Interceptor {
    func adapt(request: URLRequest) -> URLRequest?
    func retry(request: URLRequest, error: NetworkError, attempt: Int) async -> RetryResult
}

enum RetryResult {
    case retry
    case doNotRetry
    case doNotRetryWithError(Error)
}

struct AuthInterceptor: Interceptor {
    
    private let session: URLSession
    private let maxAttempt: Int
    
    init(session: URLSession = .shared, maxAttempt: Int = 3) {
        self.session = session
        self.maxAttempt = maxAttempt
    }
    
    func adapt(request: URLRequest) -> URLRequest? {
        guard let accessToken = JWTManager.shared.get()?.accessToken else { return request }
        
        var urlRequest = request
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
    func retry(request: URLRequest, error: NetworkError, attempt: Int) async -> RetryResult {
        if attempt > maxAttempt {
            return .doNotRetry
        }
        
        switch error {
        case .serverError(.unauthorized):
            do {
                try await refreshToken()
                return .retry
            } catch let error {
                NotificationCenter.default.post(name: .shouldLogin, object: nil)
                return .doNotRetryWithError(error)
            }
        default:
            return .retry
        }
    }
    
}

private extension AuthInterceptor {
    
    func refreshToken() async throws {
        guard let refreshToken = JWTManager.shared.get()?.refreshToken else { return }
        
        do {
            let request = try APIEndPoints.tokenRefresh(refreshToken: refreshToken).makeURLRequest()
            let (data, response) = try await session.data(for: request)
            
            guard let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode) else {
                throw NetworkError.refreshTokenExpired
            }
            let newToken = try JSONDecoder().decode(AuthenticationToken.self, from: data)
            try JWTManager.shared.update(token: newToken)
        } catch {
            throw error
        }
    }
    
}

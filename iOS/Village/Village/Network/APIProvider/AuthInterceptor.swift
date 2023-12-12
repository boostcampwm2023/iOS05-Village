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
        case .serverError(.forbidden):
            do {
                try await refreshToken()
                return .retry
            } catch let error {
                return .doNotRetryWithError(error)
            }
        case .serverError(.unauthorized):
            NotificationCenter.default.post(name: .shouldLogin, object: nil)
        default:
            return .retry
        }
        return .doNotRetry
    }
    
}

private extension AuthInterceptor {
    
    func refreshToken() async throws {
        do {
            guard let refreshToken = JWTManager.shared.get()?.refreshToken else { return }
            let endpoint = APIEndPoints.tokenRefresh(refreshToken: refreshToken)
            guard let newToken = try await APIProvider.shared.request(with: endpoint) else { return }
            
            try JWTManager.shared.update(token: newToken)
        }
    }
    
}

//
//  Provider.swift
//  Village
//
//  Created by 박동재 on 2023/11/21.
//

import Foundation

protocol Provider {
    func request<R: Decodable, E: Requestable&Responsable>(with endpoint: E) async throws -> R? where E.Response == R
    func request<E: Requestable>(with endpoint: E) async throws -> Data?
    func request(from url: String) async throws -> Data
}

final class APIProvider: Provider {
    
    static let shared = APIProvider(interceptor: AuthInterceptor())
    
    let session: URLSession
    private let interceptor: Interceptor?
    
    init(session: URLSession = URLSession.shared, interceptor: Interceptor? = nil) {
        self.session = session
        self.interceptor = interceptor
    }
    
    @discardableResult
    func request<R: Decodable, E: Requestable&Responsable>(with endpoint: E) async throws -> R? where E.Response == R {
        guard let data = try await sendRequest(with: endpoint) else { return nil }
        
        return try decode(data)
    }
    
    @discardableResult
    func request<E: Requestable>(with endpoint: E) async throws -> Data? {
        return try await sendRequest(with: endpoint)
    }
    
    func request(from url: String) async throws -> Data {
        guard let url = URL(string: url) else { throw NetworkError.urlRequestError }
        if let cachedImage = ImageCache.shared.getImageData(for: url as NSURL) {
            return Data(cachedImage)
        } else {
            let (data, response) = try await session.data(from: url)
            try self.checkStatusCode(response)
            ImageCache.shared.setImageData(data as NSData, for: url as NSURL)
            return data
        }
    }
    
    private func sendRequest<E: Requestable>(with endpoint: E) async throws -> Data? {
        guard let request = try? endpoint.makeURLRequest() else { return nil }
        
        var attempt = 1
        while true {
            guard let urlRequest = interceptor?.adapt(request: request) else { return nil }
            let (data, response) = try await session.data(for: urlRequest)
            do {
                try self.checkStatusCode(response)
                return data
            } catch let error as NetworkError {
                switch await interceptor?.retry(request: request, error: error, attempt: attempt) {
                case .doNotRetry:
                    throw error
                case .doNotRetryWithError(let err):
                    throw err
                default:
                    break
                }
            }
            attempt += 1
        }
    }
    
    private func checkStatusCode(_ response: URLResponse) throws {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        guard (200..<300).contains(response.statusCode) else {
            let serverError = ServerError(rawValue: response.statusCode) ?? .unknown
            throw NetworkError.serverError(serverError)
        }
    }
    
    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
}

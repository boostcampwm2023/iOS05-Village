//
//  Provider.swift
//  Village
//
//  Created by 박동재 on 2023/11/21.
//

import Foundation

protocol ProviderProtocol {
    
    func request<R: Decodable, E: RequestResponsable>(with endpoint: E) async throws -> R? where E.Response == R
    func request(from url: String) async throws -> Data
    
}

final class Provider: ProviderProtocol {
    
    static let shared = Provider()
    
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func request<R: Decodable, E: RequestResponsable>(with endpoint: E) async throws -> R? where E.Response == R {
        var urlRequest = try endpoint.makeURLRequest()
        
        let (data, response) = try await session.data(for: urlRequest)
        
        try self.checkStatusCode(response)
        if data.isEmpty {
            return nil
        }
        return try self.decode(data)
    }
    
    func request(from url: String) async throws -> Data {
        guard let url = URL(string: url) else { throw NetworkError.urlRequestError }
        let (data, response) = try await session.data(from: url)
        try self.checkStatusCode(response)
        return data
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

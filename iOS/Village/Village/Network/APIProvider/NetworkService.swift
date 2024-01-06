//
//  NetworkService.swift
//  Village
//
//  Created by 조성민 on 1/4/24.
//

import Foundation
import Combine

final class NetworkService {
    
    static let shared = NetworkService()
    
    private let interceptor = CombineAuthInterceptor()
    
    func request<R: Decodable, E: Requestable&Responsable>(_ req: E) -> AnyPublisher<R, NetworkError> where E.Response == R {
        while true {
            do {
                guard let request = interceptor.adapt(request: try req.makeURLRequest()) else {
                    throw NetworkError.urlRequestError
                }
                
                let publisher = URLSession.shared.dataTaskPublisher(for: request)
                
                return publisher
                    .tryMap { [weak self] output in
                        try self?.checkStatusCode(output.response)
                        return output.data
                    }
                    .decode(type: R.self, decoder: JSONDecoder())
                    .mapError { [weak self] error in
                        guard let networkError = error as? NetworkError else { return NetworkError.unknownError }
                        switch self?.interceptor.retry(
                            request: request,
                            error: networkError
                        ) {
                        case .doNotRetry:
                            return networkError
                        case .doNotRetryWithError(let err):
                            dump(err)
                            return NetworkError.unknownError
                        default:
                            break
                        }
                        
                        return networkError
                    }
                    .eraseToAnyPublisher()
            } catch {
                return Fail<R, NetworkError>(error: NetworkError.urlRequestError)
                    .eraseToAnyPublisher()
            }
        }
    }
    
    func request<E: Requestable>(_ req: E) -> AnyPublisher<Void, NetworkError> {
        while true {
            do {
                guard let request = interceptor.adapt(request: try req.makeURLRequest()) else {
                    throw NetworkError.urlRequestError
                }
                
                let publisher = URLSession.shared.dataTaskPublisher(for: request)
                
                return publisher
                    .tryMap { [weak self] (_, response) in
                        try self?.checkStatusCode(response)
                    }
                    .mapError { [weak self] error in
                        guard let networkError = error as? NetworkError else { return NetworkError.unknownError }
                        switch self?.interceptor.retry(
                            request: request,
                            error: networkError
                        ) {
                        case .doNotRetry:
                            return networkError
                        case .doNotRetryWithError(let err):
                            dump(err)
                            return NetworkError.unknownError
                        default:
                            break
                        }
                        
                        return networkError
                    }
                    .eraseToAnyPublisher()
            } catch {
                return Fail<Void, NetworkError>(error: NetworkError.urlRequestError)
                    .eraseToAnyPublisher()
            }
        }
    }
    
    func requestLoadImage(url: String) -> AnyPublisher<Data, NetworkError> {
        guard let url = URL(string: url) else {
            return AnyPublisher(
                Fail<Data, NetworkError>(error: NetworkError.urlRequestError)
            )
        }
        
        if let cachedImage = ImageCache.shared.getImageData(for: url as NSURL) {
            return Future<Data, NetworkError> { promise in
                promise(.success(Data(cachedImage)))
            }
            .eraseToAnyPublisher()
        } else {
            let publisher = URLSession.shared.dataTaskPublisher(for: url)
            
            return publisher
                .tryMap { (data, response) in
                    try self.checkStatusCode(response)
                    ImageCache.shared.setImageData(data as NSData, for: url as NSURL)
                    return data
                }
                .mapError { error in
                    if let networkError = error as? NetworkError {
                        return networkError
                    } else {
                        return NetworkError.unknownError
                    }
                }
                .eraseToAnyPublisher()
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
    
}

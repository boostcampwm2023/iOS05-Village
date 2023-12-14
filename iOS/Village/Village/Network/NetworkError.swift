//
//  NetworkError.swift
//  Village
//
//  Created by 박동재 on 2023/11/21.
//

import Foundation

enum NetworkError: Error {
    
    case unknownError
    case queryParameterError
    case componentsError
    case urlRequestError
    case serverError(ServerError)
    case emptyData
    case parsingError
    case refreshTokenExpired
    case decodingError(Error)
    
    var errorDescription: String {
        switch self {
        case .unknownError:
            "Unknown Error."
        case .queryParameterError:
            "Query Parameter toDictionary Failed"
        case .componentsError:
            "URL Components Error."
        case .urlRequestError:
            "URL Request Error."
        case .serverError(let serverError):
            "Server Error: \(serverError)."
        case .emptyData:
            "Empty Data."
        case .parsingError:
            "Parsing Error."
        case .decodingError(let error):
            "Decoding Error: \(error)."
        case .refreshTokenExpired:
            "Refresh Token Expired. Login again."
        }
    }
    
}

enum ServerError: Int {
    
    case unknown
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case alreadyRegister = 409
    case serverError = 500
    
}

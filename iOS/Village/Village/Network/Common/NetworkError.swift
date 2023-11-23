//
//  NetworkError.swift
//  Village
//
//  Created by 박동재 on 2023/11/21.
//

import Foundation

enum NetworkError: Error {
    
    case unknownError
    case componentsError
    case urlRequestError
    case serverError(ServerError)
    case emptyData
    case parsingError
    case decodingError(Error)
    
    var errorDescription: String {
        switch self {
        case .unknownError:
            return "Unknown Error."
        case .componentsError:
            return "URL Components Error."
        case .urlRequestError:
            return "URL Request Error."
        case .serverError(let serverError):
            return "Server Error: \(serverError)."
        case .emptyData:
            return "Empty Data."
        case .parsingError:
            return "Parsing Error."
        case .decodingError(let error):
            return "Decoding Error: \(error)."
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

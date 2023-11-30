//
//  KeychainError.swift
//  Village
//
//  Created by 정상윤 on 11/29/23.
//

import Foundation

enum KeychainError: LocalizedError {
    
    case duplicate
    case notFound
    case unknown(OSStatus)
    
    var errorDescription: String {
        switch self {
        case .duplicate:
            "토큰이 이미 키체인에 존재합니다."
        case .notFound:
            "키체인에서 토큰을 찾지 못했습니다."
        case .unknown(let status):
            "알 수 없는 에러입니다: \(status)"
        }
    }
    
}

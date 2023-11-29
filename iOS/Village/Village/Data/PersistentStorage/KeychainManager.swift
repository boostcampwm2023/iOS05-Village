//
//  KeychainManager.swift
//  Village
//
//  Created by 정상윤 on 11/29/23.
//

import Foundation
import Security

final class KeychainManager {
    
    static let shared = KeychainManager()
    
    private let server = "https://www.village-api.shop"
    
    func write(token: AuthenticationToken) throws {
        do {
            let data = try JSONEncoder().encode(token)
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: server,
                kSecValueData: data
            ]
            
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status != errSecDuplicateItem else {
                throw KeychainError.duplicate
            }
            
            guard status == errSecSuccess else {
                throw KeychainError.unknown(status)
            }
        } catch let error {
            dump(error)
        }
    }
    
}

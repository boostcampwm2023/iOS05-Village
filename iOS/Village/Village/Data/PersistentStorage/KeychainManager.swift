//
//  KeychainManager.swift
//  Village
//
//  Created by 정상윤 on 11/29/23.
//

import Foundation
import Security

struct KeychainManager<T: Codable> {
    
    func write(key: String, value: T) throws {
        do {
            let data = try JSONEncoder().encode(value)
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
                kSecValueData: data
            ]
            
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status != errSecDuplicateItem else {
                throw KeychainError.duplicate
            }
            
            guard status == errSecSuccess else {
                throw KeychainError.unknown(status)
            }
        }
    }
    
    func read(key: String) -> T? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnAttributes: true,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var result: CFTypeRef?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let result = result as? [String: AnyObject],
              let data = result[kSecValueData as String] as? Data,
              let token = try? JSONDecoder().decode(T.self, from: data) else { return nil }
        
        return token
    }
    
    func delete(key: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status != errSecItemNotFound else { throw KeychainError.notFound }
        guard status == errSecSuccess else { throw KeychainError.unknown(status) }
    }
    
    func update(key: String, newValue: T) throws {
        do {
            let data = try JSONEncoder().encode(newValue)
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key
            ]
            let attribute: [CFString: Any] = [
                kSecValueData: data
            ]
            let status = SecItemUpdate(query as CFDictionary, attribute as CFDictionary)
            
            guard status != errSecItemNotFound else { throw KeychainError.notFound }
            guard status == errSecSuccess else { throw KeychainError.unknown(status) }
        }
    }
    
}

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
    
    func write(email: String, token: AuthenticationToken) throws {
        do {
            let data = try JSONEncoder().encode(token)
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: email,
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
    
    func read(email: String) -> AuthenticationToken? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: email,
            kSecReturnAttributes: true,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard let result = result as? [String: AnyObject],
              let data = result[kSecValueData as String] as? Data,
              let token = try? JSONDecoder().decode(AuthenticationToken.self, from: data) else { return nil }
        
        return token
    }
    
    func delete(email: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: email
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status != errSecItemNotFound else { throw KeychainError.notFound }
        guard status == errSecSuccess else { throw KeychainError.unknown(status) }
    }
    
    func update(email: String, token: AuthenticationToken) throws {
        do {
            let data = try JSONEncoder().encode(token)
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
            ]
            let attribute: [CFString: Any] = [
                kSecAttrAccount: email,
                kSecValueData: data
            ]
            let status = SecItemUpdate(query as CFDictionary, attribute as CFDictionary)
            
            guard status != errSecItemNotFound else { throw KeychainError.notFound }
            guard status == errSecSuccess else { throw KeychainError.unknown(status) }
        } catch let error {
            dump(error)
        }
    }
    
}

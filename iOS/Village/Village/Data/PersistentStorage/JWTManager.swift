//
//  JWTManager.swift
//  Village
//
//  Created by 정상윤 on 11/29/23.
//

import Foundation

final class JWTManager {
    
    static let shared = JWTManager()
    
    private let keychainManager = KeychainManager<AuthenticationToken>()
    
    private let currentUserIDKey = "currentUserID"
    var currentUserID: String? {
        UserDefaults.standard.string(forKey: currentUserIDKey)
    }
    
    func get() -> AuthenticationToken? {
        guard let userID = currentUserID else { return nil }
        
        return keychainManager.read(key: userID)
    }
    
    func save(token: AuthenticationToken) throws {
        guard let userID = token.accessToken.decode()["userId"] as? String else { return }
        
        UserDefaults.standard.setValue(userID, forKey: currentUserIDKey)
        
        do {
            try keychainManager.write(key: userID, value: token)
        } catch let error as KeychainError {
            if case .duplicate = error {
                try? keychainManager.update(key: userID, newValue: token)
            }
        } catch let error {
            throw error
        }
    }
    
    func delete() throws {
        guard let userID = currentUserID else { return }
        
        try keychainManager.delete(key: userID)
        UserDefaults.standard.removeObject(forKey: currentUserIDKey)
    }
    
    func update(token: AuthenticationToken) throws {
        guard let userID = currentUserID else { return }
        
        try keychainManager.update(key: userID, newValue: token)
    }
    
}

fileprivate extension String {
    
    func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
    
    func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
              let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
              let payload = json as? [String: Any] else { return nil }
        return payload
    }
    
    func decode() -> [String: Any] {
        let segments = self.components(separatedBy: ".")
        return decodeJWTPart(segments[1]) ?? [:]
    }
    
}

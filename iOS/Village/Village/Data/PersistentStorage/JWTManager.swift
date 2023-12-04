//
//  JWTManager.swift
//  Village
//
//  Created by 정상윤 on 11/29/23.
//

import Foundation

final class JWTManager {
    
    static let shared = JWTManager()
    
    private let lastLoggedEmailKey = "lastLoggedEmail"
    private var userEmail: String? {
        UserDefaults.standard.string(forKey: lastLoggedEmailKey)
    }
    
    func get() -> AuthenticationToken? {
        guard let email = userEmail else { return nil }
        
        return KeychainManager.shared.read(email: email)
    }
    
    func save(email: String, token: AuthenticationToken) {
        UserDefaults.standard.setValue(email, forKey: lastLoggedEmailKey)
        
        do {
            try KeychainManager.shared.write(email: email, token: token)
        } catch let error as KeychainError {
            if case .duplicate = error {
                try? KeychainManager.shared.update(email: email, token: token)
            }
        } catch let error {
            dump(error)
        }
    }
    
    func delete() throws {
        guard let email = userEmail else { return }
        
        do {
            try KeychainManager.shared.delete(email: email)
        } catch let error {
            dump(error)
        }
    }
    
    func update(token: AuthenticationToken) throws {
        guard let email = userEmail else { return }
        
        do {
            try KeychainManager.shared.update(email: email, token: token)
        } catch let error {
            dump(error)
        }
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

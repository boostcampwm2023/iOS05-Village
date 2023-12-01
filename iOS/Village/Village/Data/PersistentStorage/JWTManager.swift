//
//  JWTManager.swift
//  Village
//
//  Created by 정상윤 on 11/29/23.
//

import Foundation

final class JWTManager {
    
    var tempToken: String?
    
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

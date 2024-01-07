//
//  UserDetailRepository.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation

protocol UserDetailRepository {
    
    associatedtype ResponseDTO
    
    func fetchUserData(userID: String) async -> Result<UserResponseDTO, NetworkError>
    
}

//
//  UserDetailRepository.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation
import Combine

protocol UserDetailRepository {
    
    func fetchUserData(userID: String) -> AnyPublisher<UserDetail, NetworkError>
    
}

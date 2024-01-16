//
//  DeleteChatRepository.swift
//  Village
//
//  Created by 박동재 on 1/16/24.
//

import Foundation
import Combine

protocol DeleteChatRepository {
    
    func deleteChat(roomID: Int) -> AnyPublisher<Void, NetworkError>
    
}

//
//  DefaultUserDetailRepository.swift
//  Village
//
//  Created by 박동재 on 1/7/24.
//

import Foundation

struct DefaultUserDetailRepository: UserDetailRepository {
    
    typealias ResponseDTO = UserResponseDTO
    
    private func makeEndPoint(userID: String) -> EndPoint<UserResponseDTO> {
        return EndPoint(
            baseURL: Constant.baseURL,
            path: "users/\(userID)",
            method: .GET
        )
    }
    
    func fetchUserData(userID: String) async -> Result<UserResponseDTO, NetworkError> {
        let endpoint = makeEndPoint(userID: userID)
        
        do {
            guard let responseDTO = try await APIProvider.shared.request(with: endpoint) else {
                return .failure(.emptyData)
            }
            return .success(responseDTO)
        } catch let error as NetworkError {
            return .failure(error)
        } catch {
            return .failure(.unknownError)
        }
    }
    
}

//
//  NetworkService.swift
//  Village
//
//  Created by 박동재 on 2023/11/17.
//

import Foundation

enum NetworkService {
    
    static func loadData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else { throw NetworkError.urlRequestError }
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
}

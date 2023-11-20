//
//  NetworkService.swift
//  Village
//
//  Created by 박동재 on 2023/11/17.
//

import Foundation

final class NetworkService {
    
    func loadImage(from url: URL, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }
}

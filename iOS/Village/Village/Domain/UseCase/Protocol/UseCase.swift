//
//  UseCase.swift
//  Village
//
//  Created by 조성민 on 12/22/23.
//

import Foundation
import Combine

protocol UseCase {
    
    associatedtype ResultValue
    
    func start() -> AnyPublisher<ResultValue, NetworkError>
    
}

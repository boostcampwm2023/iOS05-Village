//
//  PostingViewModel.swift
//  Village
//
//  Created by 조성민 on 11/21/23.
//

import Foundation
import Combine

final class PostingViewModel {
    
    @Published var titleInput: String = ""
    @Published var priceInput: String = ""
    @Published var detailInput: String = ""
    
    struct Input {
        
        let title: AnyPublisher<String, Never>
        let startTime: AnyPublisher<String, Never>
        let endTime: AnyPublisher<String, Never>
        let price: AnyPublisher<Int, Never>
        let detail: AnyPublisher<String, Never>
        
    }
    
    struct Output {
        
        let postButtonValid: AnyPublisher<Bool, Never>
        
    }
    
    init() {
        
    }
    
//    func transform(input: Input) -> Output {
//        return Output(postButtonValid: )
//    }
    
}

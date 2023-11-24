//
//  PostDetailViewModel.swift
//  Village
//
//  Created by 정상윤 on 11/24/23.
//

import Foundation
import Combine

final class PostDetailViewModel {
    
    private var post = PassthroughSubject<PostResponseDTO, NetworkError>()
    private var user = PassthroughSubject<UserResponseDTO, NetworkError>()
    private var cancellableBag = Set<AnyCancellable>()
    
    func transform(input: Input) -> Output {
        input.postID
            .sink(receiveValue: { [weak self] id in
                self?.getPost(id: id)
            })
            .store(in: &cancellableBag)
        
        input.userID
            .sink(receiveValue: { [weak self] id in
                self?.getUser(id: id)
            })
            .store(in: &cancellableBag)
        
        return Output(post: post.eraseToAnyPublisher(), user: user.eraseToAnyPublisher())
    }
    
    private func getPost(id: Int) {
        let endpoint = APIEndPoints.getPost(id: id)
        
        Task {
            do {
                let data = try await Provider.shared.request(with: endpoint)
                post.send(data)
            } catch let error as NetworkError {
                post.send(completion: .failure(error))
            }
        }
    }
    
    private func getUser(id: Int) {
        let endpoint = APIEndPoints.getUser(id: id)
        
        Task {
            do {
                let data = try await Provider.shared.request(with: endpoint)
                user.send(data)
            } catch let error as NetworkError {
                user.send(completion: .failure(error))
            }
        }
    }
    
}

extension PostDetailViewModel {
    
    struct Input {
        var postID: AnyPublisher<Int, Never>
        var userID: AnyPublisher<Int, Never>
    }
    
    struct Output {
        var post: AnyPublisher<PostResponseDTO, NetworkError>
        var user: AnyPublisher<UserResponseDTO, NetworkError>
    }
    
}
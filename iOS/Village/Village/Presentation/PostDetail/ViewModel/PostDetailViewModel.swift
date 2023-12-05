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
    private var responseData: PostRoomResponseDTO?
    private var cancellableBag = Set<AnyCancellable>()
    
    func createChatRoom(writer: String, postID: Int) -> PostRoomResponseDTO? {
        let request = PostRoomRequestDTO(writer: writer, postID: postID)
        let endpoint = APIEndPoints.postCreateChatRoom(with: request)
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                print(data)
                responseData = data
            } catch let error as NetworkError {
                dump(error)
            }
        }
        
        return responseData
    }
    
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
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                post.send(data)
            } catch let error as NetworkError {
                post.send(completion: .failure(error))
            }
        }
    }
    
    private func getUser(id: String) {
        let endpoint = APIEndPoints.getUser(id: id)
        
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
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
        var userID: AnyPublisher<String, Never>
    }
    
    struct Output {
        var post: AnyPublisher<PostResponseDTO, NetworkError>
        var user: AnyPublisher<UserResponseDTO, NetworkError>
    }
    
}

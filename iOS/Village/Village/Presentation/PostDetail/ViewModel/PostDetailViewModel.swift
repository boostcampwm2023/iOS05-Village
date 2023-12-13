//
//  PostDetailViewModel.swift
//  Village
//
//  Created by 정상윤 on 11/24/23.
//

import Foundation
import Combine

final class PostDetailViewModel {
    
    private let postID: Int
    private var userID: String = ""
    
    private let post = PassthroughSubject<PostResponseDTO, NetworkError>()
    private let user = PassthroughSubject<UserResponseDTO, NetworkError>()
    private let imageData = PassthroughSubject<[Data], Error>()
    private let roomID = PassthroughSubject<PostRoomResponseDTO, NetworkError>()
    private let moreOutput = PassthroughSubject<String, Never>()
    private let modifyOutput = PassthroughSubject<PostResponseDTO, NetworkError>()
    private let reportOutput = PassthroughSubject<(postID: Int, userID: String), Never>()
    private let deleteOutput = PassthroughSubject<Void, NetworkError>()
    private let popViewControllerOutput = PassthroughSubject<Void, NetworkError>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    init(postID: Int) {
        self.postID = postID
        
        self.getPost()
    }
    
    func transformPost(input: Input) -> Output {
        input.makeRoomID.sink { [weak self] _ in
            self?.createChatRoom()
        }
        .store(in: &cancellableBag)
        
        input.moreInput.sink { [weak self] _ in
            guard let self = self else { return }
            self.moreOutput.send(self.userID)
        }
        .store(in: &cancellableBag)
        
        input.modifyInput.sink { [weak self] _ in
            guard let self = self else { return }
            self.updatePost(id: self.postID)
        }
        .store(in: &cancellableBag)
        
        input.reportInput.sink { [weak self] _ in
            guard let self = self else { return }
            self.reportOutput.send((self.postID, self.userID))
        }
        .store(in: &cancellableBag)
        
        input.deleteInput.sink { [weak self] _ in
            self?.deletePost()
        }
        .store(in: &cancellableBag)
        
        input.hideInput.sink { [weak self] _ in
            self?.hidePost()
        }
        .store(in: &cancellableBag)
        
        input.blockUserInput.sink { [weak self] _ in
            self?.blockUser()
        }
        .store(in: &cancellableBag)
        
        input.refreshInput
            .sink { [weak self] _ in
                self?.getPost()
            }
            .store(in: &cancellableBag)
        
        return Output(
            post: post.eraseToAnyPublisher(),
            user: user.eraseToAnyPublisher(),
            imageData: imageData.eraseToAnyPublisher(),
            moreOutput: moreOutput.eraseToAnyPublisher(),
            roomID: roomID.eraseToAnyPublisher(),
            reportOutput: reportOutput.eraseToAnyPublisher(),
            modifyOutput: modifyOutput.eraseToAnyPublisher(),
            deleteOutput: deleteOutput.eraseToAnyPublisher(),
            popViewControllerOutput: popViewControllerOutput.eraseToAnyPublisher()
        )
    }
    
    func getPost() {
        let endpoint = APIEndPoints.getPost(id: postID)
      
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                post.send(data)
                self.userID = data.userID
                self.getUser(id: self.userID)
                self.getImageData(images: data.images)
            } catch let error as NetworkError {
                post.send(completion: .failure(error))
            }
        }
    }
    
}

private extension PostDetailViewModel {
    
    func updatePost(id: Int) {
        let endpoint = APIEndPoints.getPost(id: id)
        
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                modifyOutput.send(data)
            } catch let error as NetworkError {
                modifyOutput.send(completion: .failure(error))
            }
        }
    }
    
    func getUser(id: String) {
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
    
    func getImageData(images: [String]) {
        Task {
            do {
                let data = try await getData(urls: images)
                imageData.send(data)
            } catch {
                imageData.send(completion: .failure(error))
            }
        }
    }
    
    func getData(urls: [String]) async throws -> [Data] {
        return try await withThrowingTaskGroup(of: Data.self, returning: [Data].self) { taskGroup in
            urls.forEach { url in
                taskGroup.addTask { try await APIProvider.shared.request(from: url) }
            }
            var imageData = [Data]()
            for try await data in taskGroup {
                imageData.append(data)
            }
            return imageData
        }
    }
    
    func createChatRoom() {
        let request = PostRoomRequestDTO(writer: self.userID, postID: self.postID)
        let endpoint = APIEndPoints.postCreateChatRoom(with: request)
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                roomID.send(data)
            } catch let error as NetworkError {
                dump(error)
                roomID.send(completion: .failure(error))
            }
        }
    }
    
    func deletePost() {
        let endpoint = APIEndPoints.deletePost(with: self.postID)
        
        Task {
            do {
                try await APIProvider.shared.request(with: endpoint)
                PostNotificationPublisher.shared.publishPostDeleted(postID: postID)
                deleteOutput.send()
            } catch let error as NetworkError {
                deleteOutput.send(completion: .failure(error))
            }
        }
    }
    
    func hidePost() {
        let endpoint = APIEndPoints.hidePost(postID: self.postID)
        
        Task {
            do {
                try await APIProvider.shared.request(with: endpoint)
                PostNotificationPublisher.shared.publishPostDeleted(postID: postID)
                popViewControllerOutput.send()
            } catch let error as NetworkError {
                popViewControllerOutput.send(completion: .failure(error))
            } catch {
                dump(error)
            }
        }
    }
    
    func blockUser() {
        let endpoint = APIEndPoints.blockUser(userID: self.userID)
        
        Task {
            do {
                try await APIProvider.shared.request(with: endpoint)
                PostNotificationPublisher.shared.publishPostRefreshAll()
                popViewControllerOutput.send()
            } catch let error as NetworkError {
                popViewControllerOutput.send(completion: .failure(error))
            } catch {
                dump(error)
            }
        }
    }
    
}

extension PostDetailViewModel {
    
    struct Input {
        let makeRoomID: AnyPublisher<Void, Never>
        let moreInput: AnyPublisher<Void, Never>
        let modifyInput: AnyPublisher<Void, Never>
        let reportInput: AnyPublisher<Void, Never>
        let deleteInput: AnyPublisher<Void, Never>
        let hideInput: AnyPublisher<Void, Never>
        let blockUserInput: AnyPublisher<Void, Never>
        let refreshInput: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let post: AnyPublisher<PostResponseDTO, NetworkError>
        let user: AnyPublisher<UserResponseDTO, NetworkError>
        let imageData: AnyPublisher<[Data], Error>
        let moreOutput: AnyPublisher<String, Never>
        let roomID: AnyPublisher<PostRoomResponseDTO, NetworkError>
        let reportOutput: AnyPublisher<(postID: Int, userID: String), Never>
        let modifyOutput: AnyPublisher<PostResponseDTO, NetworkError>
        let deleteOutput: AnyPublisher<Void, NetworkError>
        let popViewControllerOutput: AnyPublisher<Void, NetworkError>
    }
    
}

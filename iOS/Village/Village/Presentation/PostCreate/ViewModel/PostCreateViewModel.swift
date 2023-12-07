//
//  PostCreateViewModel.swift
//  Village
//
//  Created by 조성민 on 11/21/23.
//

import Foundation
import Combine

struct PostWarning {
    
    let titleWarning: Bool
    let startTimeWarning: Bool
    let endTimeWarning: Bool
    let priceWarning: Bool?
    
    var validation: Bool {
        !(titleWarning && startTimeWarning && endTimeWarning && priceWarning == nil ||
        titleWarning && startTimeWarning && endTimeWarning && priceWarning == true)
    }
    
}

struct PostModifyInfo {
    
    let title: String
    let startTime: String
    let endTime: String
    let price: String?
    let detail: String
    
}

final class PostCreateViewModel {
    
    let isRequest: Bool
    let isEdit: Bool
    let postID: Int?
    
    private let warningPublisher = PassthroughSubject<PostWarning, Never>()
    private let endOutput = PassthroughSubject<PostResponseDTO?, NetworkError>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private let useCase: PostCreateUseCase
    
    func priceToInt(price: String?) -> Int? {
        guard var price = price else { return nil }
        price = price.replacingOccurrences(of: ".", with: "")
        
        return Int(price)
    }
    
    func modifyPost(post: PostModifyInfo) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        guard let startTime = dateFormatter.date(from: post.startTime),
              let endTime = dateFormatter.date(from: post.endTime) else { return }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let startTimeString = dateFormatter.string(from: startTime)
        let endTimeString = dateFormatter.string(from: endTime)
        
        let modifyEndPoint = APIEndPoints.modifyPost(
            with: PostModifyRequestDTO(
                postInfo: PostInfoDTO(
                    title: post.title,
                    description: post.detail,
                    price: priceToInt(price: post.price),
                    isRequest: isRequest,
                    startDate: startTimeString,
                    endDate: endTimeString
                ),
                image: [],
                postID: postID
            )
        )
        
        Task {
            do {
                try await APIProvider.shared.request(with: modifyEndPoint)
                if isEdit {
                    updatePost()
                }
                endOutput.send(nil)
            } catch let error as NetworkError {
                self.endOutput.send(completion: .failure(error))
            } catch {
                dump("Unknown Error")
            }
        }
    }
    
    func updatePost() {
        guard let id = postID else {
            endOutput.send(nil)
            return
        }
        let getPostEndpoint = APIEndPoints.getPost(id: id)
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: getPostEndpoint) else {
                    self.endOutput.send(nil)
                    return
                }
                self.endOutput.send(data)
            } catch let error as NetworkError {
                self.endOutput.send(completion: .failure(error))
            }
        }
    }
    
    init(useCase: PostCreateUseCase, isRequest: Bool, isEdit: Bool, postID: Int? = nil) {
        self.useCase = useCase
        self.isRequest = isRequest
        self.isEdit = isEdit
        self.postID = postID
    }
    
    func transform(input: Input) -> Output {
        
        input.postInfoInput
            .sink { [weak self] post in
                guard let self = self else { return }
                let warning = PostWarning(
                    titleWarning: post.title.isEmpty,
                    startTimeWarning: post.startTime.isEmpty,
                    endTimeWarning: post.endTime.isEmpty,
                    priceWarning: post.price?.isEmpty
                )
                if warning.validation {
                    modifyPost(post: post)
                } else {
                    warningPublisher.send(warning)
                }
            }
            .store(in: &cancellableBag)
        
        return Output(
            warningResult: warningPublisher.eraseToAnyPublisher(),
            endResult: endOutput.eraseToAnyPublisher()
        )
    }
    
}

extension PostCreateViewModel {
    
    struct Input {
        
        var postInfoInput: PassthroughSubject<PostModifyInfo, Never>
        
    }
    
    struct Output {
        
        var warningResult: AnyPublisher<PostWarning, Never>
        var endResult: AnyPublisher<PostResponseDTO?, NetworkError>
        
    }
    
}

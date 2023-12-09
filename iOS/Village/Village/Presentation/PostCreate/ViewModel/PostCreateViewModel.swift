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
    let timeSequenceWarning: Bool
    
    var validation: Bool {
        !(titleWarning || startTimeWarning || endTimeWarning || timeSequenceWarning || priceWarning == true)
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
    private let endOutput = PassthroughSubject<Void, NetworkError>()
    private let editInitPublisher = PassthroughSubject<PostInfoDTO, Never>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private let useCase: PostCreateUseCase
    
    func priceToInt(price: String?) -> Int? {
        if isRequest { return nil }
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
                endOutput.send()
            } catch let error as NetworkError {
                self.endOutput.send(completion: .failure(error))
            } catch {
                dump("Unknown Error")
            }
        }
    }
    
    init(useCase: PostCreateUseCase, isRequest: Bool, isEdit: Bool, postID: Int? = nil) {
        self.useCase = useCase
        self.isRequest = isRequest
        self.isEdit = isEdit
        self.postID = postID
    }
    
    func setEdit() {
        guard let id = postID else { return }
        let endpoint = APIEndPoints.getPost(id: id)
        
        Task {
            do {
                guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                
                editInitPublisher.send(
                    PostInfoDTO(
                        title: data.title,
                        description: data.description,
                        price: data.price,
                        isRequest: data.isRequest,
                        startDate: data.startDate,
                        endDate: data.endDate
                    )
                )
            } catch {
                dump(error)
            }
        }
    }
    
    func timeSequenceWarn(startTimeString: String, endTimeString: String) -> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        if startTimeString.isEmpty || endTimeString.isEmpty {
            return false
        }
        guard let startTime = dateFormatter.date(from: startTimeString),
              let endTime = dateFormatter.date(from: endTimeString) else { return false }
        return startTime.timeIntervalSince1970 - endTime.timeIntervalSince1970 >= 0
    }
    
    func transform(input: Input) -> Output {
        
        input.postInfoInput
            .sink { [weak self] post in
                guard let self = self else { return }
                
                let warning = PostWarning(
                    titleWarning: post.title.isEmpty,
                    startTimeWarning: post.startTime.isEmpty,
                    endTimeWarning: post.endTime.isEmpty,
                    priceWarning: isRequest ? nil : post.price?.isEmpty,
                    timeSequenceWarning: timeSequenceWarn(startTimeString: post.startTime, endTimeString: post.endTime)
                )
                if warning.validation == true {
                    modifyPost(post: post)
                } else {
                    warningPublisher.send(warning)
                }
            }
            .store(in: &cancellableBag)
        
        input.editSetInput
            .sink { [weak self] in
                self?.setEdit()
            }
            .store(in: &cancellableBag)
        
        return Output(
            warningResult: warningPublisher.eraseToAnyPublisher(),
            endResult: endOutput.eraseToAnyPublisher(),
            editInitOutput: editInitPublisher.eraseToAnyPublisher()
        )
    }
    
}

extension PostCreateViewModel {
    
    struct Input {
        
        var postInfoInput: PassthroughSubject<PostModifyInfo, Never>
        var editSetInput: PassthroughSubject<Void, Never>
        
    }
    
    struct Output {
        
        var warningResult: AnyPublisher<PostWarning, Never>
        var endResult: AnyPublisher<Void, NetworkError>
        var editInitOutput: AnyPublisher<PostInfoDTO, Never>
        
    }
    
}

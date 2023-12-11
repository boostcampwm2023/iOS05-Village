//
//  PostCreateViewModel.swift
//  Village
//
//  Created by 조성민 on 11/21/23.
//

import Foundation
import Combine

struct PostWarning {
    
    let imageWarning: Bool?
    let titleWarning: Bool
    let startTimeWarning: Bool
    let endTimeWarning: Bool
    let priceWarning: Bool?
    let timeSequenceWarning: Bool
    
    var validation: Bool {
        !(imageWarning == true
          || titleWarning
          || startTimeWarning
          || endTimeWarning
          || timeSequenceWarning
          || priceWarning == true)
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
    private var images = [ImageItem]()
    var imagesCount: Int {
        images.count
    }
    private var willDeleteImageURL = [String]()
    private var isLoading: Bool = false
    
    private let warningPublisher = PassthroughSubject<PostWarning, Never>()
    private let endOutput = PassthroughSubject<Void, NetworkError>()
    private let editInitPublisher = PassthroughSubject<PostInfoDTO, Never>()
    private let imageOutput = PassthroughSubject<[ImageItem], Never>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private let useCase: PostCreateUseCase
    
    func priceToInt(price: String?) -> Int? {
        if isRequest { return nil }
        guard var price = price else { return nil }
        price = price.replacingOccurrences(of: ".", with: "")
        
        return Int(price)
    }
    
    func modifyPost(post: PostModifyInfo, images: [Data]) {
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
                    endDate: endTimeString,
                    deletedImages: willDeleteImageURL
                ),
                image: images,
                postID: postID
            )
        )
        
        Task {
            do {
                try await APIProvider.shared.request(with: modifyEndPoint)
                if let id = postID {
                    NotificationCenter.default.post(name: .postEdited, object: nil, userInfo: ["postID": id])
                } else {
                    NotificationCenter.default.post(name: .postCreated, object: nil)
                }
                endOutput.send()
            } catch let error as NetworkError {
                self.endOutput.send(completion: .failure(error))
            } catch {
                dump("Unknown Error")
            }
            isLoading = false
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
                        endDate: data.endDate,
                        deletedImages: []
                    )
                )
                setEditImage(imageURL: data.images)
            } catch {
                dump(error)
            }
        }
    }
    
    private func setEditImage(imageURL: [String]) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let items = try await self.getImageItems(imageURL)
                self.images += items
                self.imageOutput.send(items)
            } catch {
                dump(error)
            }
        }
    }
    
    private func getImageItems(_ urls: [String]) async throws -> [ImageItem] {
        return try await withThrowingTaskGroup(of: (Data, String).self, returning: [ImageItem].self) { taskGroup in
            urls.forEach { url in
                taskGroup.addTask { (try await APIProvider.shared.request(from: url), url) }
            }
            var imageData = [ImageItem]()
            for try await (data, url) in taskGroup {
                let item = ImageItem(data: data, url: url)
                imageData.append(item)
            }
            return imageData
        }
    }
    
    private func timeSequenceWarn(startTimeString: String, endTimeString: String) -> Bool {
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
                self?.setPost(post: post)
            }
            .store(in: &cancellableBag)
        
        input.editSetInput
            .sink { [weak self] in
                self?.setEdit()
            }
            .store(in: &cancellableBag)
        
        input.selectedImagePublisher
            .sink { [weak self] data in
                let imageItems = data.map { ImageItem(data: $0) }
                self?.images += imageItems
                self?.imageOutput.send(imageItems)
            }
            .store(in: &cancellableBag)
        
        input.deleteImagePublisher
            .sink { [weak self] item in
                self?.deleteImage(item: item)
            }
            .store(in: &cancellableBag)
        
        return Output(
            warningResult: warningPublisher.eraseToAnyPublisher(),
            endResult: endOutput.eraseToAnyPublisher(),
            editInitOutput: editInitPublisher.eraseToAnyPublisher(),
            imageOutput: imageOutput.eraseToAnyPublisher()
        )
    }
    
    private func setPost(post: PostModifyInfo) {
        guard isLoading == false else { return }
        isLoading = true
        let warning = PostWarning(
            imageWarning: self.isRequest ? nil : imagesCount == 0,
            titleWarning: post.title.isEmpty,
            startTimeWarning: post.startTime.isEmpty,
            endTimeWarning: post.endTime.isEmpty,
            priceWarning: self.isRequest ? nil : post.price?.isEmpty,
            timeSequenceWarning: timeSequenceWarn(startTimeString: post.startTime, endTimeString: post.endTime)
        )
        if warning.validation == true {
            modifyPost(post: post, images: images.filter { $0.url == nil }.map(\.data))
        } else {
            warningPublisher.send(warning)
            isLoading = false
        }
    }
    
    private func deleteImage(item: ImageItem) {
        if let url = item.url {
            willDeleteImageURL.append(url)
        }
        images.removeAll(where: {$0.id == item.id})
    }
    
}

extension PostCreateViewModel {
    
    struct Input {
        
        var postInfoInput: PassthroughSubject<PostModifyInfo, Never>
        var editSetInput: PassthroughSubject<Void, Never>
        var selectedImagePublisher: AnyPublisher<[Data], Never>
        var deleteImagePublisher: AnyPublisher<ImageItem, Never>
        
    }
    
    struct Output {
        
        var warningResult: AnyPublisher<PostWarning, Never>
        var endResult: AnyPublisher<Void, NetworkError>
        var editInitOutput: AnyPublisher<PostInfoDTO, Never>
        var imageOutput: AnyPublisher<[ImageItem], Never>
        
    }
    
}

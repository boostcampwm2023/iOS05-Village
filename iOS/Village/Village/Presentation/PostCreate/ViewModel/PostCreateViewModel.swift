//
//  PostCreateViewModel.swift
//  Village
//
//  Created by 조성민 on 11/21/23.
//

import Foundation
import Combine

final class PostCreateViewModel {
    
    let isRequest: Bool
    let isEdit: Bool
    let postID: Int?
    
    private var titleInput: String = ""
    private var startTimeInput: Date?
    private var endTimeInput: Date?
    private var priceInput: Int?
    private var detailInput: String = ""
    
    private var isValidTitle: Bool = false
    private var isValidStartTime: Bool = false
    private var isValidEndTime: Bool = false
    private var isValidPrice: Bool = false
    private var isValidPostCreate: Bool {
        let rentBool =
        !isRequest &&
        isValidTitle &&
        isValidStartTime &&
        isValidEndTime &&
        isValidPrice
        let requestBool =
        isRequest &&
        isValidTitle &&
        isValidStartTime &&
        isValidEndTime
        
        return rentBool || requestBool
    }
    
    private let priceOutput = PassthroughSubject<String, Never>()
    private let postButtonTappedTitleWarningOutput = PassthroughSubject<Bool, Never>()
    private let postButtonTappedStartTimeWarningOutput = PassthroughSubject<Bool, Never>()
    private let postButtonTappedEndTimeWarningOutput = PassthroughSubject<Bool, Never>()
    private let postButtonTappedPriceWarningOutput = PassthroughSubject<Bool, Never>()
    private let endOutput = PassthroughSubject<Void, Never>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private let useCase: PostUseCase
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return formatter
    }()
    
    func execute() {
        guard let startTime = startTimeInput,
              let endTime = endTimeInput else { return }
        let startTimeString = formatter.string(from: startTime)
        let endTimeString = formatter.string(from: endTime)
        guard let id = postID else { return }
        
        let postModifyDTO = PostModifyDTO(
            postInfo: PostInfoDTO(
                title: titleInput,
                description: detailInput,
                price: priceInput,
                isRequest: isRequest,
                startDate: startTimeString,
                endDate: endTimeString
            ),
            image: [],
            postID: id
        )
        useCase.execute(with: postModifyDTO)
    }
    
    init(useCase: PostCreateUseCase, isRequest: Bool, isEdit: Bool, postID: Int?) {
        self.useCase = useCase
        self.isRequest = isRequest
        self.isEdit = isEdit
        self.postID = postID
    }
    
    func transform(input: Input) -> Output {
        input.titleSubject
            .sink { [weak self] text in
                self?.titleInput = text
            }
            .store(in: &cancellableBag)
        
        input.startTimeSubject
            .sink { [weak self] date in
                self?.startTimeInput = date
            }
            .store(in: &cancellableBag)
        
        input.endTimeSubject
            .sink { [weak self] date in
                self?.endTimeInput = date
            }
            .store(in: &cancellableBag)
        
        if !isRequest {
            input.priceSubject
                .sink(receiveValue: { [weak self] priceString in
                    let price = priceString.replacingOccurrences(of: ",", with: "")
                    if let priceInt = Int(price) {
                        self?.priceOutput.send(priceInt.priceText())
                        self?.priceInput = priceInt
                    } else if priceString.isEmpty {
                        self?.priceOutput.send("")
                        self?.priceInput = nil
                    } else {
                        guard let prevPriceInt = self?.priceInput else {
                            self?.priceOutput.send("")
                            self?.priceInput = nil
                            return
                        }
                        self?.priceOutput.send(prevPriceInt.priceText())
                    }
                })
                .store(in: &cancellableBag)
        }
        
        input.detailSubject
            .sink { [weak self] detailText in
                self?.detailInput = detailText
            }
            .store(in: &cancellableBag)
        
        input.postButtonTappedSubject
            .sink { [weak self] () in
                guard let self = self else { return }
                validate()
                if isValidPostCreate {
                    execute()
                    endOutput.send()
                } else {
                    postButtonTappedTitleWarningOutput.send(isValidTitle)
                    postButtonTappedStartTimeWarningOutput.send(isValidStartTime)
                    postButtonTappedEndTimeWarningOutput.send(isValidEndTime)
                    if !isRequest {
                        postButtonTappedPriceWarningOutput.send(isValidPrice)
                    }
                }
            }
            .store(in: &cancellableBag)
        return Output(
            priceValidationResult: priceOutput.eraseToAnyPublisher(),
            postButtonTappedTitleWarningResult: postButtonTappedTitleWarningOutput.eraseToAnyPublisher(),
            postButtonTappedStartTimeWarningResult: postButtonTappedStartTimeWarningOutput.eraseToAnyPublisher(),
            postButtonTappedEndTimeWarningResult: postButtonTappedEndTimeWarningOutput.eraseToAnyPublisher(),
            postButtonTappedPriceWarningResult: postButtonTappedPriceWarningOutput.eraseToAnyPublisher(),
            endResult: endOutput.eraseToAnyPublisher()
        )
    }
    
    func setEdit(post: PostResponseDTO) {
        titleInput = post.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
        startTimeInput = formatter.date(from: post.startDate)
        endTimeInput = formatter.date(from: post.endDate)
        if !isRequest {
            priceInput = post.price
        }
        detailInput = post.description
        validate()
    }
    
}

private extension PostCreateViewModel {
    
    func validate() {
        validateTitle()
        validateStartTime()
        validateEndTime()
        validatePrice()
    }
    
    func validateTitle() {
        let result = !titleInput.isEmpty
        isValidTitle = result
    }
    
    func validateStartTime() {
        let result = startTimeInput != nil
        isValidStartTime = result
    }
    
    func validateEndTime() {
        let result = endTimeInput != nil
        isValidEndTime = result
    }
    
    func validatePrice() {
        let result = priceInput != nil
        isValidPrice = result
    }
    
}

extension PostCreateViewModel {
    
    struct Input {
        
        var titleSubject: CurrentValueSubject<String, Never>
        var startTimeSubject: CurrentValueSubject<Date?, Never>
        var endTimeSubject: CurrentValueSubject<Date?, Never>
        var priceSubject: CurrentValueSubject<String, Never>
        var detailSubject: CurrentValueSubject<String, Never>
        var postButtonTappedSubject: PassthroughSubject<Void, Never>
        
    }
    
    struct Output {
        
        var priceValidationResult: AnyPublisher<String, Never>
        var postButtonTappedTitleWarningResult: AnyPublisher<Bool, Never>
        var postButtonTappedStartTimeWarningResult: AnyPublisher<Bool, Never>
        var postButtonTappedEndTimeWarningResult: AnyPublisher<Bool, Never>
        var postButtonTappedPriceWarningResult: AnyPublisher<Bool, Never>
        var endResult: AnyPublisher<Void, Never>
        
    }
    
}

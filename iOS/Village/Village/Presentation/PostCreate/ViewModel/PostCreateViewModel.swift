//
//  PostCreateViewModel.swift
//  Village
//
//  Created by 조성민 on 11/21/23.
//

import Foundation
import Combine

final class PostCreateViewModel {
    
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
        isValidTitle &&
        isValidStartTime &&
        isValidEndTime &&
        isValidPrice
    }
    
    private let priceOutput = PassthroughSubject<String, Never>()
    private let postButtonTappedTitleWarningOutput = PassthroughSubject<Bool, Never>()
    private let postButtonTappedStartTimeWarningOutput = PassthroughSubject<Bool, Never>()
    private let postButtonTappedEndTimeWarningOutput = PassthroughSubject<Bool, Never>()
    private let postButtonTappedPriceWarningOutput = PassthroughSubject<Bool, Never>()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private let useCase: PostCreateUseCase
    private var postCreateTask: Cancellable? {
        willSet {
            postCreateTask?.cancel()
        }
    }
    
    func postCreate() {
        
//        postCreateTask = useCase.execute(
//            requestValue: PostCreateDTO(
//                title: <#T##String#>,
//                contents: <#T##String#>,
//                price: <#T##Int?#>,
//                isRequest: <#T##Bool#>,
//                images: <#T##[String]#>,
//                startDate: <#T##String#>,
//                endDate: <#T##String#>
//            ),
//            completion: {
//                <#code#>
//            }
//        )
    }
    
    init(useCase: PostCreateUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        input.titleSubject
            .sink { [weak self] text in
                self?.titleInput = text
                self?.validateTitle()
            }
            .store(in: &cancellableBag)
        
        input.startTimeSubject
            .sink { [weak self] date in
                self?.startTimeInput = date
                self?.validateStartTime()
            }
            .store(in: &cancellableBag)
        
        input.endTimeSubject
            .sink { [weak self] date in
                self?.endTimeInput = date
                self?.validateEndTime()
            }
            .store(in: &cancellableBag)
        
        input.priceSubject
            .sink(receiveValue: { [weak self] priceString in
                let price = priceString.replacingOccurrences(of: ",", with: "")
                if let priceInt = Int(price) {
                    self?.priceOutput.send(priceInt.priceText())
                    self?.priceInput = priceInt
                    self?.validatePrice()
                } else if priceString.isEmpty {
                    self?.priceOutput.send("")
                    self?.priceInput = nil
                    self?.validatePrice()
                } else {
                    guard let prevPriceInt = self?.priceInput else {
                        self?.priceOutput.send("")
                        self?.priceInput = nil
                        self?.validatePrice()
                        return
                    }
                    self?.priceOutput.send(prevPriceInt.priceText())
                }
            })
            .store(in: &cancellableBag)
        
        input.detailSubject
            .sink { [weak self] detailText in
                self?.detailInput = detailText
            }
            .store(in: &cancellableBag)
        
        input.postButtonTappedSubject
            .sink { [weak self] () in
                if let titleValidation = self?.isValidTitle {
                    self?.postButtonTappedTitleWarningOutput.send(titleValidation)
                }
                if let startTimeValidation = self?.isValidStartTime {
                    self?.postButtonTappedStartTimeWarningOutput.send(startTimeValidation)
                }
                if let endTimeValidation = self?.isValidEndTime {
                    self?.postButtonTappedEndTimeWarningOutput.send(endTimeValidation)
                }
                if let priceValidation = self?.isValidPrice {
                    self?.postButtonTappedPriceWarningOutput.send(priceValidation)
                }
                guard let validation = self?.isValidPostCreate else { return }
                // TODO: post객체 만들어서 네트워킹
            }
            .store(in: &cancellableBag)
        return Output(
            priceValidationResult: priceOutput.eraseToAnyPublisher(),
            postButtonTappedTitleWarningResult: postButtonTappedTitleWarningOutput.eraseToAnyPublisher(),
            postButtonTappedStartTimeWarningResult: postButtonTappedStartTimeWarningOutput.eraseToAnyPublisher(),
            postButtonTappedEndTimeWarningResult: postButtonTappedEndTimeWarningOutput.eraseToAnyPublisher(),
            postButtonTappedPriceWarningResult: postButtonTappedPriceWarningOutput.eraseToAnyPublisher()
        )
    }
    
}

private extension PostCreateViewModel {
    
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
        
    }
    
}

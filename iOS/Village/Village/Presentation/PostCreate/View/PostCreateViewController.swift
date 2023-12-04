//
//  PostCreateViewController.swift
//  Village
//
//  Created by 조성민 on 11/15/23.
//

import UIKit
import Combine

enum PostType {
    
    case rent
    case request
    
}

final class PostCreateViewController: UIViewController {
    
    private let viewModel: PostCreateViewModel
    private var postButtonTappedSubject = PassthroughSubject<Void, Never>()
    
    private lazy var keyboardToolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        let hideKeyboardButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: nil,
            action: #selector(hideKeyboard)
        )
        let flexibleSpaceButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        toolbar.sizeToFit()
        toolbar.setItems([flexibleSpaceButton, hideKeyboardButton], animated: false)
        toolbar.tintColor = .label
        
        return toolbar
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        
        return stackView
    }()
    
    private lazy var scrollViewBottomConstraint: NSLayoutConstraint = {
        return scrollView.bottomAnchor.constraint(equalTo: postButtonView.topAnchor, constant: 0)
    }()
    
    private lazy var postCreateTitleView: PostCreateTitleView = {
        let view = PostCreateTitleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postCreateStartTimeView: PostCreateTimeView = {
        let view = PostCreateTimeView(postType: viewModel.postType, timeType: .start)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postCreateEndTimeView: PostCreateTimeView = {
        let view = PostCreateTimeView(postType: viewModel.postType, timeType: .end)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postCreatePriceView: PostCreatePriceView = {
        let view = PostCreatePriceView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postCreateDetailView: PostCreateDetailView = {
        let view = PostCreateDetailView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let postButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        if viewModel.isEdit {
            configuration.title = "편집완료"
        } else {
            configuration.title = "작성하기"
        }
        configuration.titleAlignment = .center
        configuration.baseBackgroundColor = .primary500
        configuration.cornerStyle = .medium
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(post), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        
        configureNavigation()
        configureUI()
        configureConstraints()
        setUpNotification()
        bind()
        
        view.backgroundColor = .systemBackground
        super.viewDidLoad()
    }
    
    init(viewModel: PostCreateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var cancellableBag: Set<AnyCancellable> = []
    
    func bind() {
        let input = PostCreateViewModel.Input(
            titleSubject: postCreateTitleView.currentTextSubject,
            startTimeSubject: postCreateStartTimeView.currentTimeSubject,
            endTimeSubject: postCreateEndTimeView.currentTimeSubject,
            priceSubject: postCreatePriceView.currentPriceSubject,
            detailSubject: postCreateDetailView.currentDetailSubject,
            postButtonTappedSubject: postButtonTappedSubject
        )
        handleViewModelOutput(output: viewModel.transform(input: input))
    }
    
    func handleViewModelOutput(output: PostCreateViewModel.Output) {
        subscribePriceOutput(output: output)
    }
    
    func subscribePriceOutput(output: PostCreateViewModel.Output) {
        output.priceValidationResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] prevPriceString in
                self?.postCreatePriceView.revertChange(text: prevPriceString)
            }
            .store(in: &cancellableBag)
        
        output.postButtonTappedTitleWarningResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bool in
                self?.postCreateTitleView.warn(!bool)
            }
            .store(in: &cancellableBag)
        
        output.postButtonTappedStartTimeWarningResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bool in
                self?.postCreateStartTimeView.warn(!bool)
            }
            .store(in: &cancellableBag)
        
        output.postButtonTappedEndTimeWarningResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bool in
                self?.postCreateEndTimeView.warn(!bool)
            }
            .store(in: &cancellableBag)
        
        output.postButtonTappedPriceWarningResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bool in
                self?.postCreatePriceView.warn(!bool)
            }
            .store(in: &cancellableBag)
    }
    
}

@objc
private extension PostCreateViewController {
    
    func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    func post(_ sender: UIButton) {
        postButtonTappedSubject.send()
    }
    
    func hideKeyboard(_ sender: UIBarButtonItem) {
        view.endEditing(true)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo as NSDictionary?,
              var keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        keyboardFrame = view.convert(keyboardFrame, from: nil)
        NSLayoutConstraint.deactivate([scrollViewBottomConstraint])
        scrollViewBottomConstraint = scrollView
            .bottomAnchor
            .constraint(
                equalTo: view.bottomAnchor,
                constant: -keyboardFrame.height
            )
        NSLayoutConstraint.activate([scrollViewBottomConstraint])
    }
    
    func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo as NSDictionary?,
              var keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        keyboardFrame = view.convert(keyboardFrame, from: nil)
        NSLayoutConstraint.deactivate([scrollViewBottomConstraint])
        scrollViewBottomConstraint = scrollView
            .bottomAnchor
            .constraint(
                equalTo: postButtonView.topAnchor,
                constant: 0
            )
        NSLayoutConstraint.activate([scrollViewBottomConstraint])
    }
    
}

private extension PostCreateViewController {
    
    func setUpNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func configureUI() {
        view.addSubview(postButtonView)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        postButtonView.addSubview(postButton)
        
        stackView.addArrangedSubview(postCreateTitleView)
        stackView.addArrangedSubview(postCreateStartTimeView)
        stackView.addArrangedSubview(postCreateEndTimeView)
        
        if viewModel.postType == .rent {
            stackView.addArrangedSubview(postCreatePriceView)
        }
        
        stackView.addArrangedSubview(postCreateDetailView)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            postButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            postButtonView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollViewBottomConstraint
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 25),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -25),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            postButton.topAnchor.constraint(equalTo: postButtonView.topAnchor, constant: 18),
            postButton.leadingAnchor.constraint(equalTo: postButtonView.leadingAnchor, constant: 16),
            postButton.trailingAnchor.constraint(equalTo: postButtonView.trailingAnchor, constant: -16),
            postButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            postCreateTitleView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50),
            postCreateStartTimeView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50),
            postCreateEndTimeView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50),
            postCreateDetailView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50)
        ])
        
        if viewModel.postType == .rent {
            NSLayoutConstraint.activate([
                postCreatePriceView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50)
            ])
        }
    }
    
    func configureNavigation() {
        let titleLabel = UILabel()
        switch viewModel.postType {
        case .rent:
            titleLabel.setTitle("대여 등록")
        case .request:
            titleLabel.setTitle("대여 요청 등록")
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        let close = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(close), symbolName: .xmark
        )
        self.navigationItem.rightBarButtonItems = [close]
        self.navigationItem.backButtonDisplayMode = .minimal
    }
    
}

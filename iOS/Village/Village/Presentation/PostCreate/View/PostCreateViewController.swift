//
//  PostCreateViewController.swift
//  Village
//
//  Created by 조성민 on 11/15/23.
//

import UIKit
import Combine

final class PostCreateViewController: UIViewController {
    
    private let viewModel: PostCreateViewModel
    var editButtonTappedSubject = PassthroughSubject<PostResponseDTO?, Never>()
    private var postInfoPublisher = PassthroughSubject<PostModifyInfo, Never>()
    
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
        let view = PostCreateTimeView(isRequest: viewModel.isRequest, timeType: .start)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postCreateEndTimeView: PostCreateTimeView = {
        let view = PostCreateTimeView(isRequest: viewModel.isRequest, timeType: .end)
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
    
    var cancellableBag: Set<AnyCancellable> = []
    
    private func bind() {
        let input = PostCreateViewModel.Input(
            postInfoInput: postInfoPublisher
        )
        
        let output = viewModel.transform(input: input)
        
        output.warningResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] warning in
                self?.postCreateTitleView.warn(warning.titleWarning)
                self?.postCreateStartTimeView.warn(warning.startTimeWarning)
                self?.postCreateEndTimeView.warn(warning.endTimeWarning)
                if let priceWarning = warning.priceWarning {
                    self?.postCreatePriceView.warn(priceWarning)
                }
            }
            .store(in: &cancellableBag)
        
        output.endResult
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            }, receiveValue: { [weak self] post in
                self?.dismiss(animated: true)
                self?.navigationController?.popViewController(animated: true)
                
                // TODO: edit인 경우 해야함
                guard let isEdit = self?.viewModel.isEdit else { return }
                if isEdit {
                    self?.editButtonTappedSubject.send(post)
                }
            })
            .store(in: &cancellableBag)
        
    }
    
    func setEdit(post: PostResponseDTO) {
//        postCreateTitleView.setEdit(title: post.title)
//        postCreateDetailView.setEdit(detail: post.description)
//        postCreateStartTimeView.setEdit(time: post.startDate)
//        postCreateEndTimeView.setEdit(time: post.endDate)
//        if !post.isRequest {
//            postCreatePriceView.setEdit(price: post.price)
//        }
    }
    
}

@objc
private extension PostCreateViewController {
    
    func close(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    func post(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ""
        postInfoPublisher.send(
            PostModifyInfo(
                title: postCreateTitleView.titleTextField.text ?? "",
                startTime: postCreateStartTimeView.timeString,
                endTime: postCreateEndTimeView.timeString,
                price: postCreatePriceView.priceTextField.text ?? "",
                detail: postCreateDetailView.detailTextView.text ?? ""
            )
        )
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
        
        if !viewModel.isRequest {
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
        
        if !viewModel.isRequest {
            NSLayoutConstraint.activate([
                postCreatePriceView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50)
            ])
        }
    }
    
    func configureNavigation() {
        let titleLabel = UILabel()
        if viewModel.isRequest {
            if viewModel.isEdit {
                titleLabel.setTitle("대여 요청 등록 편집")
            } else {
                titleLabel.setTitle("대여 요청 등록")
            }
        } else {
            if viewModel.isEdit {
                titleLabel.setTitle("대여 등록 편집")
            } else {
                titleLabel.setTitle("대여 등록")
            }
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        let close = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(close), symbolName: .xmark
        )
        self.navigationItem.rightBarButtonItems = [close]
        self.navigationItem.backButtonDisplayMode = .minimal
    }
    
}

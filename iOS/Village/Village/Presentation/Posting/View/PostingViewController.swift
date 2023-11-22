//
//  PostingViewController.swift
//  Village
//
//  Created by 조성민 on 11/15/23.
//

import UIKit

final class PostingViewController: UIViewController {
    
    private let viewModel: PostingViewModel
    private let type: PostType
    
    private lazy var keyboardToolBar: UIToolbar = {
        let toolbar = UIToolbar()
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
    
    private lazy var postingTitleView: PostingTitleView = {
        let view = PostingTitleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postingPriceView: PostingPriceView = {
        let view = PostingPriceView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var periodStartHeaderLabel: UILabel = {
        let label = UILabel()
        switch type {
        case .rent:
            label.text = "대여 시작 가능"
        case .request:
            label.text = "대여 시작"
        }
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    private let periodEndHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "대여 종료"
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    private let detailHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "자세한 설명"
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    private let startTimeWarningLabel: UILabel = {
        let label = UILabel()
        label.text = "시간을 선택해야 합니다."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .negative400
        label.alpha = 0
        
        return label
    }()
    
    private let endTimeWarningLabel: UILabel = {
        let label = UILabel()
        label.text = "시간을 선택해야 합니다."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .negative400
        label.alpha = 0
        
        return label
    }()
    
    private let startTimePicker: TimePickerView = {
        let picker = TimePickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        return picker
    }()
    
    private let endTimePicker: TimePickerView = {
        let picker = TimePickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        return picker
    }()
    
    
    private lazy var detailTextView: UITextView = {
        let textView = UITextView()
        textView.setLayer()
        textView.textContainerInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        textView.text = "설명을 입력하세요."
        textView.textColor = .lightGray
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isScrollEnabled = false
        textView.inputAccessoryView = keyboardToolBar
        textView.delegate = self
        
        return textView
    }()
    
    private let postButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var postButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "작성하기"
        configuration.titleAlignment = .center
        configuration.baseBackgroundColor = .primary500
        configuration.cornerStyle = .medium
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(post), for: .touchUpInside)
        
        return button
    }()
    
    private var isEmptyStartTime: Bool {
        if startTimePicker.time == nil {
            return true
        }
        return false
    }
    
    private var isEmptyEndTime: Bool {
        if endTimePicker.time == nil {
            return true
        }
        return false
    }
    
    override func viewDidLoad() {
        
        configureNavigation()
        configureUI()
        configureConstraints()
        setUpNotification()
        
        view.backgroundColor = .systemBackground
        super.viewDidLoad()
    }
    
    init(viewModel: PostingViewModel, type: PostType) {
        self.viewModel = viewModel
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

@objc
private extension PostingViewController {
    
    func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // TODO: 작성하기 버튼 눌렀을 때 작동 구현
    func post(_ sender: UIButton) {
//        if isEmptyTitle {
//            titleWarningLabel.alpha = 1
//        }
        if isEmptyStartTime {
            startTimeWarningLabel.alpha = 1
        }
        if isEmptyEndTime {
            endTimeWarningLabel.alpha = 1
        }
//        if isEmptyPrice {
//            priceWarningLabel.alpha = 1
//        }
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

private extension PostingViewController {
    
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
        
        stackView.addArrangedSubview(postingTitleView)
        
        stackView.addArrangedSubview(periodStartHeaderLabel)
        stackView.addArrangedSubview(startTimePicker)
        stackView.addArrangedSubview(startTimeWarningLabel)
        
        stackView.addArrangedSubview(periodEndHeaderLabel)
        stackView.addArrangedSubview(endTimePicker)
        stackView.addArrangedSubview(endTimeWarningLabel)
        
        if type == .rent {
            stackView.addArrangedSubview(postingPriceView)
        }
        
        stackView.addArrangedSubview(detailHeaderLabel)
        stackView.addArrangedSubview(detailTextView)
        
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
            startTimePicker.heightAnchor.constraint(equalToConstant: 50),
            endTimePicker.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            detailTextView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        NSLayoutConstraint.activate([
            postButton.topAnchor.constraint(equalTo: postButtonView.topAnchor, constant: 18),
            postButton.leadingAnchor.constraint(equalTo: postButtonView.leadingAnchor, constant: 16),
            postButton.trailingAnchor.constraint(equalTo: postButtonView.trailingAnchor, constant: -16),
            postButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            postingTitleView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50),
            detailTextView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50)
        ])
        
        if type == .rent {
            NSLayoutConstraint.activate([
                postingPriceView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50)
            ])
        }
    }
    
    func configureNavigation() {
        let titleLabel = UILabel()
        switch type {
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
    }
    
}

extension PostingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

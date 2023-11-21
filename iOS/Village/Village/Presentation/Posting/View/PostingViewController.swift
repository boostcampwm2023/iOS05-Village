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
    
    private let titleHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "제목"
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
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
    
    private let priceHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "하루 대여 가격"
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    private let detailHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "자세한 설명"
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.setLayer()
        textField.setPlaceHolder("제목을 입력하세요")
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.rightViewMode = .always
        textField.inputAccessoryView = keyboardToolBar
        textField.delegate = self
        
        return textField
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
    
    private lazy var priceTextField: UITextField = {
        let textField = UITextField()
        textField.setLayer()
        textField.setPlaceHolder("가격을 입력하세요")
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        
        let label = UILabel()
        label.text = "원  "
        textField.rightView = label
        textField.rightViewMode = .always
        
        textField.inputAccessoryView = keyboardToolBar
        textField.delegate = self
        textField.keyboardType = .numberPad
        
        return textField
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
        
        stackView.addArrangedSubview(titleHeaderLabel)
        stackView.addArrangedSubview(titleTextField)
        stackView.setCustomSpacing(25, after: titleTextField)
        
        stackView.addArrangedSubview(periodStartHeaderLabel)
        stackView.addArrangedSubview(startTimePicker)
        stackView.setCustomSpacing(25, after: startTimePicker)
        
        stackView.addArrangedSubview(periodEndHeaderLabel)
        stackView.addArrangedSubview(endTimePicker)
        stackView.setCustomSpacing(25, after: endTimePicker)
        
        if type == .rent {
            stackView.addArrangedSubview(priceHeaderLabel)
            stackView.addArrangedSubview(priceTextField)
            stackView.setCustomSpacing(25, after: priceTextField)
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
            titleTextField.heightAnchor.constraint(equalToConstant: 48),
            titleTextField.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50),
            detailTextView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50)
        ])
        
        if type == .rent {
            NSLayoutConstraint.activate([
                priceTextField.heightAnchor.constraint(equalToConstant: 48),
                priceTextField.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50)
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
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if textField == priceTextField {
            guard var text = textField.text else { return true }
            text = text.replacingOccurrences(of: ",", with: "")
            if !string.isEmpty && Int(string) == nil || text.count + string.count > 15 { return false }
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            
            if string.isEmpty {
                if text.count > 1 {
                    guard let price = Int.init("\(text.prefix(text.count - 1))"),
                          let result = numberFormatter.string(from: NSNumber(value: price)) else { return true }
                    textField.text = "\(result)"
                } else {
                    textField.text = ""
                }
            } else {
                guard let price = Int.init("\(text)\(string)"),
                      let result = numberFormatter.string(from: NSNumber(value: price)) else { return true }
                textField.text = "\(result)"
            }
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

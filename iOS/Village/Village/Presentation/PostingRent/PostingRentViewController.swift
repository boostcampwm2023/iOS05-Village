//
//  PostingRentViewController.swift
//  Village
//
//  Created by 조성민 on 11/15/23.
//

import UIKit

final class PostingRentViewController: UIViewController {
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
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private lazy var scrollViewBottomConstraint: NSLayoutConstraint = {
        return scrollView.bottomAnchor.constraint(equalTo: postButtonView.topAnchor, constant: 0)
    }()
    //    private let photoHeaderLabel = UILabel()
    //    private let addPhotoButton = UIButton()
    private let titleHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "제목"
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    private let periodStartHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "대여 시작 가능"
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
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        textField.delegate = self
        textField.inputAccessoryView = keyboardToolBar
        
        return textField
    }()
    private let startTimePicker = TimePickerView()
    private let endTimePicker = TimePickerView()
    
    private lazy var priceTextFieldView: UIView = {
        let view = UIView()
        view.setLayer()
        let textField = UITextField()
        textField.setPlaceHolder("가격을 입력하세요")
        let rightView = UILabel()
        rightView.text = "원"
        textField.rightView = rightView
        textField.rightViewMode = .always
        textField.delegate = self
        view.heightAnchor.constraint(equalToConstant: 48).isActive = true
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        textField.inputAccessoryView = keyboardToolBar
        
        return view
    }()
    private let detailTextViewPlaceHolder = "설명을 입력하세요."
    private lazy var detailTextView: UITextView = {
        let textView = UITextView()
        textView.setLayer()
        textView.textContainerInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        textView.text = self.detailTextViewPlaceHolder
        textView.textColor = .lightGray
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isScrollEnabled = false
        textView.inputAccessoryView = keyboardToolBar
        
        return textView
    }()
    
    private let postButtonView = UIView()
    private lazy var postButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "작성하기"
        configuration.titleAlignment = .center
        configuration.baseBackgroundColor = .primary500
        configuration.cornerStyle = .medium
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(post), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        configureUIComponents()
        setUpNotification()
        super.viewDidLoad()
    }
    
    @objc func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // TODO: 작성하기 버튼 눌렀을 때 작동 구현
    @objc func post(_ sender: UIButton) {
    }
    
    private func setUpNotification() {
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
    
    @objc private func hideKeyboard(_ sender: UIBarButtonItem) {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
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
    @objc private func keyboardWillHide(_ notification: Notification) {
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

private extension PostingRentViewController {
    
    func configureUIComponents() {
        configureNavigation()
        configurePostButtonView()
        configureScrollView()
        configureStackView()
        configurePicker()
        configureDetailTextView()
        configurePostButton()
        configureInputViews()
    }
    
    func configureNavigation() {
        let titleLabel = UILabel()
        titleLabel.setTitle("대여 등록")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        let close = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(close), symbolName: .xmark
        )
        self.navigationItem.rightBarButtonItems = [close]
    }
    
    func configurePostButtonView() {
        postButtonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(postButtonView)
        
        NSLayoutConstraint.activate([
            postButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            postButtonView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([scrollViewBottomConstraint])
    }
    
    func configureStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 25),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -25),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        stackView.addArrangedSubview(titleHeaderLabel)
        stackView.addArrangedSubview(titleTextField)
        stackView.setCustomSpacing(25, after: titleTextField)
        stackView.addArrangedSubview(periodStartHeaderLabel)
        stackView.addArrangedSubview(startTimePicker)
        stackView.setCustomSpacing(25, after: startTimePicker)
        stackView.addArrangedSubview(periodEndHeaderLabel)
        stackView.addArrangedSubview(endTimePicker)
        stackView.setCustomSpacing(25, after: endTimePicker)
        stackView.addArrangedSubview(priceHeaderLabel)
        stackView.addArrangedSubview(priceTextFieldView)
        stackView.setCustomSpacing(25, after: priceTextFieldView)
        stackView.addArrangedSubview(detailHeaderLabel)
        stackView.addArrangedSubview(detailTextView)
        stackView.axis = .vertical
        stackView.spacing = 10
    }
    
    func configurePicker() {
        startTimePicker.translatesAutoresizingMaskIntoConstraints = false
        startTimePicker.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        endTimePicker.translatesAutoresizingMaskIntoConstraints = false
        endTimePicker.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func configureDetailTextView() {
        detailTextView.delegate = self
        detailTextView.heightAnchor.constraint(equalToConstant: 180).isActive = true
    }
    
    func configurePostButton() {
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButtonView.addSubview(postButton)
        
        NSLayoutConstraint.activate([
            postButton.topAnchor.constraint(equalTo: postButtonView.topAnchor, constant: 18),
            postButton.leadingAnchor.constraint(equalTo: postButtonView.leadingAnchor, constant: 16),
            postButton.trailingAnchor.constraint(equalTo: postButtonView.trailingAnchor, constant: -16),
            postButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configureInputViews() {
        NSLayoutConstraint.activate([
            titleTextField.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50),
            priceTextFieldView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50),
            detailTextView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50)
        ])
    }
    
}

extension PostingRentViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if estimatedSize.height > 180 && constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == detailTextViewPlaceHolder {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = detailTextViewPlaceHolder
            textView.textColor = .lightGray
        }
    }
    
}

extension PostingRentViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension UIStackView {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    
}

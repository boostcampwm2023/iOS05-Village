//
//  PostingRentViewController.swift
//  Village
//
//  Created by 조성민 on 11/15/23.
//

import UIKit

final class PostingRentViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
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
        
        return textView
    }()
    
    private let postButtonView = UIView()
    private lazy var postButtonViewBottomConstraint = postButtonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
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
        view.backgroundColor = .white
        setNavigationUI()
        setPostButtonView()
        configureUIComponents()
        setupKeyboardEvent()
        super.viewDidLoad()
    }
    
    @objc func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // TODO: 작성하기 버튼 눌렀을 때 작동 구현
    @objc func post(_ sender: UIButton) {
    }
    
    func setupKeyboardEvent() {
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
    
    @objc func keyboardWillShow(_ sender: Notification) {
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        NSLayoutConstraint.deactivate([postButtonViewBottomConstraint])
        postButtonViewBottomConstraint = postButtonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -keyboardHeight)
        
        NSLayoutConstraint.activate([postButtonViewBottomConstraint])
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        NSLayoutConstraint.deactivate([postButtonViewBottomConstraint])
        postButtonViewBottomConstraint = postButtonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        NSLayoutConstraint.activate([postButtonViewBottomConstraint])
    }
    
}

private extension PostingRentViewController {
    
    func configureUIComponents() {
        configureDetailTextView()
        configureStackView()
        configurePicker()
    }
    
    func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: postButtonView.topAnchor)
        ])
    }
    
    func configureStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 25),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -25),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50)
        ])
        
        stackView.addArrangedSubview(titleHeaderLabel)
        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(periodStartHeaderLabel)
        stackView.addArrangedSubview(startTimePicker)
        stackView.addArrangedSubview(periodEndHeaderLabel)
        stackView.addArrangedSubview(endTimePicker)
        stackView.addArrangedSubview(priceHeaderLabel)
        stackView.addArrangedSubview(priceTextFieldView)
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
    
    func setPostButton() {
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButtonView.addSubview(postButton)
        NSLayoutConstraint.activate([
            postButton.topAnchor.constraint(equalTo: postButtonView.topAnchor, constant: 18),
            postButton.leadingAnchor.constraint(equalTo: postButtonView.leadingAnchor, constant: 16),
            postButton.trailingAnchor.constraint(equalTo: postButtonView.trailingAnchor, constant: -16),
            postButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func setPostButtonView() {
        postButtonView.setLayer(cornerRadius: 0)
        postButtonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(postButtonView)
        
        NSLayoutConstraint.activate([
            postButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postButtonView.heightAnchor.constraint(equalToConstant: 100)
        ])
        NSLayoutConstraint.activate([postButtonViewBottomConstraint])
    }
    
    func setNavigationUI() {
        let titleLabel = UILabel()
        titleLabel.setTitle("대여 등록")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        let close = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(close), symbolName: .xmark
        )
        self.navigationItem.rightBarButtonItems = [close]
        navigationController?.navigationBar.backgroundColor = .white
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
            textView.textColor = .black
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

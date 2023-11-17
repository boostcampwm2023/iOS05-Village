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
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목을 입력하세요"
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 8
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return textField
    }()
    private let startTimePicker = TimePickerView()
    private let endTimePicker = TimePickerView()
    
    private let priceTextFieldView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 8
        let textField = UITextField()
        textField.placeholder = "가격을 입력하세요"
        let rightView = UILabel()
        rightView.text = "원"
        textField.rightView = rightView
        textField.rightViewMode = .always
        view.heightAnchor.constraint(equalToConstant: 48).isActive = true
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    private let detailTextViewPlaceHolder = "설명을 입력하세요."
    private let detailTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 0.5
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textContainerInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        return textView
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        setNavigationUI()
        configureUIComponents()
        super.viewDidLoad()
    }
    
    private func setNavigationUI() {
        let titleLabel = UILabel()
        titleLabel.setTitle("대여 등록")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        let close = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(close), symbolName: .xmark
        )
        self.navigationItem.rightBarButtonItems = [close]
    }
    
    @objc func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}

private extension PostingRentViewController {
    
    func configureUIComponents() {
        configureStackView()
        configurePicker()
        configureDetailTextView()
    }
    
    func configureStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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
        detailTextView.isScrollEnabled = false
        detailTextView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        detailTextView.text = detailTextViewPlaceHolder
        detailTextView.textColor = .lightGray
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

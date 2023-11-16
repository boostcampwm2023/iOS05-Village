//
//  PostingRentViewController.swift
//  Village
//
//  Created by 조성민 on 11/15/23.
//

import UIKit

class PostingRentViewController: UIViewController {
    
    private let stackView = UIStackView()
    //    private let photoHeaderLabel = UILabel()
    //    private let addPhotoButton = UIButton()
    private let titleHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "제목"
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    private let periodHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "대여 가능 기간"
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
    private let periodPicker = TimePickerView()
    
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
    private let detailTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 0.5
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainerInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        return textView
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        configureUIComponents()
        super.viewDidLoad()
    }
    
}

private extension PostingRentViewController {
    
    func configureUIComponents() {
        configureStackView()
        configurePeriodPicker()
    }
    
    func configureStackView() {
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        stackView.addArrangedSubview(titleHeaderLabel)
        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(periodHeaderLabel)
        stackView.addArrangedSubview(periodPicker)
        stackView.addArrangedSubview(priceHeaderLabel)
        stackView.addArrangedSubview(priceTextFieldView)
        stackView.addArrangedSubview(detailHeaderLabel)
        stackView.addArrangedSubview(detailTextView)
        stackView.axis = .vertical
        stackView.spacing = 10
    }
    
    func configurePeriodPicker() {
        periodPicker.translatesAutoresizingMaskIntoConstraints = false
        periodPicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
}

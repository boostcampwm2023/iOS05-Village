//
//  PostingTitleView.swift
//  Village
//
//  Created by 조성민 on 11/22/23.
//

import UIKit

final class PostingTitleView: UIView {
    
    private let titleHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "제목"
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
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
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
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
    
    private let titleWarningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "제목을 작성해야 합니다."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .negative400
        label.alpha = 0
        
        return label
    }()
    
    @objc func hideKeyboard(_ sender: UIBarButtonItem) {
        endEditing(true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension PostingTitleView {
    
    func configureUI() {
        addSubview(titleHeaderLabel)
        addSubview(titleTextField)
        addSubview(titleWarningLabel)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            titleHeaderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            titleHeaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: titleHeaderLabel.bottomAnchor, constant: 10),
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            titleTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            titleWarningLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
            titleWarningLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        ])
    }
}

extension PostingTitleView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text else { return true }
        if !string.isEmpty && text.count + string.count > 64 { return false }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

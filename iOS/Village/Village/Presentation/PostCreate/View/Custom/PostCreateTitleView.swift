//
//  PostCreateTitleView.swift
//  Village
//
//  Created by 조성민 on 11/22/23.
//

import UIKit
import Combine

final class PostCreateTitleView: UIStackView {
    
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
    
    private let titleHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "제목"
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    lazy var titleTextField: UITextField = {
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
    
    let titleWarningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "제목을 작성해야 합니다."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .negative400
        label.alpha = 0
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
        configureUI()
        configureConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func hideKeyboard(_ sender: UIBarButtonItem) {
        endEditing(true)
    }
    
    func warn(_ enable: Bool) {
        let alpha: CGFloat = enable ? 1 : 0
        titleWarningLabel.alpha = alpha
    }
    
}

private extension PostCreateTitleView {
    
    func setUp() {
        spacing = 10
        axis = .vertical
    }
    
    func configureUI() {
        addArrangedSubview(titleHeaderLabel)
        addArrangedSubview(titleTextField)
        addArrangedSubview(titleWarningLabel)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
}

extension PostCreateTitleView: UITextFieldDelegate {
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = textField.text else { return true }
        if !string.isEmpty && text.count + string.count > 64 { return false }
        warn(false)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

//
//  PostingPriceView.swift
//  Village
//
//  Created by 조성민 on 11/22/23.
//

import UIKit

final class PostingPriceView: UIStackView {
    
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
    
    private let priceHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "하루 대여 가격"
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    private lazy var priceTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
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
    
    private let priceWarningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "하루 대여 가격을 설정해야 합니다."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .negative400
        label.alpha = 0
        
        return label
    }()
    
    private var isEmptyPrice: Bool {
        guard let text = priceTextField.text else { return true }
        
        return text.isEmpty
    }
    
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
    
}

private extension PostingPriceView {
    
    func setUp() {
        spacing = 10
        axis = .vertical
    }
    
    func configureUI() {
        addArrangedSubview(priceHeaderLabel)
        addArrangedSubview(priceTextField)
        addArrangedSubview(priceWarningLabel)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            priceTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
}

extension PostingPriceView: UITextFieldDelegate {
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

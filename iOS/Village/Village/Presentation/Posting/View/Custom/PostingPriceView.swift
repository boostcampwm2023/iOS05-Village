//
//  PostingPriceView.swift
//  Village
//
//  Created by 조성민 on 11/22/23.
//

import UIKit
import Combine

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
        textField.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        
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
    
    @objc private func textFieldDidChanged(_ sender: UITextField) {
        guard var text = sender.text else { return }
        priceWarningLabel.alpha = 0
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        text = text.replacingOccurrences(of: ",", with: "")
        guard let price = Int.init(text),
              let string = numberFormatter.string(from: NSNumber(value: price)) else { return }
        sender.text = string
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
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension PostingPriceView {
    
    var publisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: priceTextField)
            .compactMap { $0.object as? UITextField }
            .map { ($0.text ?? "") }
            .print()
            .eraseToAnyPublisher()
    }
    
}

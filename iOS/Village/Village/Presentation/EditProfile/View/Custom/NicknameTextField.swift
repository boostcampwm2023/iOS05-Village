//
//  UIView.swift
//  Village
//
//  Created by 정상윤 on 11/27/23.
//

import UIKit
import Combine

final class NicknameTextField: UIView {
    
    var nicknameText = PassthroughSubject<String, Never>()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = .boldSystemFont(ofSize: 15)
        
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.delegate = self
        textField.setLayer(borderColor: .systemGray4)
        
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        setLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("should not be called")
    }
    
    @objc
    private func textFieldDidChange() {
        nicknameText.send(textField.text ?? "")
    }
    
    func setNickname(nickname: String?) {
        textField.text = nickname
    }

}

private extension NicknameTextField {
    
    func configureUI() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textField)
    }
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        textField.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
}

extension NicknameTextField: UITextFieldDelegate {
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if !string.isEmpty {
            do {
                let regex = try NSRegularExpression(pattern: "^[0-9ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z_]+$")
                let range = NSRange(location: 0, length: string.utf16.count)
                guard regex.firstMatch(in: string, range: range) != nil else { return false }
            } catch {
                return false
            }
        }
        guard let text = textField.text else { return false }
        
        if text.count + string.count > 10 {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

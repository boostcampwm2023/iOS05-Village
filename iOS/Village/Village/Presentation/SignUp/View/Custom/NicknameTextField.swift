//
//  UIView.swift
//  Village
//
//  Created by 정상윤 on 11/27/23.
//

import UIKit
import Combine

final class NicknameTextField: UIView {

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
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
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

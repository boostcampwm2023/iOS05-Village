//
//  ChatRoomViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/20.
//

import UIKit

final class ChatRoomViewController: UIViewController {
    
    private let keyboardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        
        return stackView
    }()
    
    private let keyboardMoreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: ImageSystemName.plus.rawValue), for: .normal)
        
        return button
    }()
    
    private let keyboardTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "메시지를 입력해주세요."
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .grey100
        
        return textField
    }()
    
    private let keyboardSendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: ImageSystemName.paperplane.rawValue), for: .normal)
        
        return button
    }()
    
    private let postSummaryView = PostSummaryView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationUI()
        setUI()
        
        view.backgroundColor = .systemBackground
    }
    
    private func setUI() {
        view.addSubview(postSummaryView)
        
        keyboardTextField.delegate = self
        
        keyboardStackView.addArrangedSubview(keyboardMoreButton)
        keyboardStackView.addArrangedSubview(keyboardTextField)
        keyboardStackView.addArrangedSubview(keyboardSendButton)
        view.addSubview(keyboardStackView)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        
        NSLayoutConstraint.activate([
            keyboardStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            keyboardMoreButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            keyboardTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            keyboardSendButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
    }
    
    private func setNavigationUI() {
        let arrowLeft = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(backButtonTapped), symbolName: .arrowLeft
        )
        let ellipsis = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(ellipsisTapped), symbolName: .ellipsis
        )
        
        navigationItem.title = "다른 사용자"
        navigationItem.leftBarButtonItem = arrowLeft
        navigationItem.rightBarButtonItem = ellipsis
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func ellipsisTapped() {
        // TODO: 더보기 버튼 클릭 액션
    }
    
}

extension ChatRoomViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

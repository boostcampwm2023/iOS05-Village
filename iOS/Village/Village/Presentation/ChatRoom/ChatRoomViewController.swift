//
//  ChatRoomViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/20.
//

import UIKit

class ChatRoomViewController: UIViewController {
    
    let postView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: ImageSystemName.photo.rawValue)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .primary100
        imageView.layer.cornerRadius = 16
        
        return imageView
    }()
    
    let postTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "닌텐도 스위치"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        
        return label
    }()
    
    let postPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "10000원"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        
        return label
    }()
    
    let postAccessoryView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: ImageSystemName.chevronRight.rawValue)
        
        return imageView
    }()
    
    let chatStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        
        return stackView
    }()
    
    let chatMoreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: ImageSystemName.plus.rawValue), for: .normal)
        
        return button
    }()
    
    let chatTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "메시지를 입력해주세요."
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .grey100
        
        return textField
    }()
    
    let chatSendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: ImageSystemName.paperplane.rawValue), for: .normal)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationUI()
        setUI()
        
        view.backgroundColor = .systemBackground
    }
    
    private func setUI() {
        
        postView.addSubview(postImageView)
        postView.addSubview(postTitleLabel)
        postView.addSubview(postPriceLabel)
        postView.addSubview(postAccessoryView)
        view.addSubview(postView)
        
        chatTextField.delegate = self
        
        chatStackView.addArrangedSubview(chatMoreButton)
        chatStackView.addArrangedSubview(chatTextField)
        chatStackView.addArrangedSubview(chatSendButton)
        view.addSubview(chatStackView)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        
        NSLayoutConstraint.activate([
            postView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            postView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: postView.topAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: postView.leadingAnchor, constant: 10),
            postImageView.widthAnchor.constraint(equalToConstant: 80),
            postImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            postTitleLabel.topAnchor.constraint(equalTo: postView.topAnchor, constant: 25),
            postTitleLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            postPriceLabel.topAnchor.constraint(equalTo: postTitleLabel.bottomAnchor, constant: 10),
            postPriceLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            postAccessoryView.topAnchor.constraint(equalTo: postView.topAnchor, constant: 39),
            postAccessoryView.trailingAnchor.constraint(equalTo: postView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            chatStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            chatMoreButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            chatTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            chatSendButton.widthAnchor.constraint(equalToConstant: 40)
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

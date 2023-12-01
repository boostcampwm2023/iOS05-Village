//
//  SignUpViewController.swift
//  Village
//
//  Created by 정상윤 on 11/27/23.
//

import UIKit

final class SignUpViewController: UIViewController {
    
    private lazy var navigationBar: UINavigationBar = {
        let bar = UINavigationBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.tintColor = .label
        
        return bar
    }()
    
    private lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "완료"
        button.isEnabled = false
        
        return button
    }()
    
    private lazy var profileImageView: ProfileImageView = {
        let imageView = ProfileImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageClicked)))
        
        return imageView
    }()
    
    private lazy var nicknameTextField: NicknameTextField = {
        let textField = NicknameTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNavigationBar()
        setLayoutConstraints()
    }
    
    @objc
    private func imageClicked() {
        dump("Image Clicked")
    }

}

private extension SignUpViewController {
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(navigationBar)
        view.addSubview(profileImageView)
        view.addSubview(nicknameTextField)
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationItem.title = "프로필 설정"
        navigationBar.standardAppearance = appearance
        navigationBar.pushItem(navigationItem, animated: false)
        navigationBar.topItem?.rightBarButtonItem = doneButton
    }
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nicknameTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20)
        ])
    }
    
}

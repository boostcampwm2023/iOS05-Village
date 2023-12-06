//
//  BlockedUserTableViewCell.swift
//  Village
//
//  Created by 박동재 on 12/6/23.
//

import UIKit

class BlockedUserTableViewCell: UITableViewCell {
    
    private lazy var userView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 18
        imageView.backgroundColor = .primary500
        
        return imageView
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        
        return label
    }()
    
    private lazy var blockedButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.titleAlignment = .center
        configuration.baseBackgroundColor = .primary500
        var titleAttribute = AttributedString.init("차단 해제")
        titleAttribute.font = .systemFont(ofSize: 12.0, weight: .bold)
        configuration.attributedTitle = titleAttribute
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(target, action: #selector(muteButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func muteButtonTapped() {
        if blockedButton.titleLabel?.text == "차단 해제" {
            blockedButton.configuration?.baseBackgroundColor = .black
            var titleAttribute = AttributedString.init("차단")
            titleAttribute.font = .systemFont(ofSize: 12.0, weight: .bold)
            blockedButton.configuration?.attributedTitle = titleAttribute
        } else {
            blockedButton.configuration?.baseBackgroundColor = .primary500
            var titleAttribute = AttributedString.init("차단 해제")
            titleAttribute.font = .systemFont(ofSize: 12.0, weight: .bold)
            blockedButton.configuration?.attributedTitle = titleAttribute
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        self.contentView.addSubview(userView)
        self.userView.addSubview(profileImageView)
        self.userView.addSubview(nicknameLabel)
        self.userView.addSubview(blockedButton)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            userView.topAnchor.constraint(equalTo: self.topAnchor),
            userView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            userView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            userView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            userView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: userView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: userView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 36),
            profileImageView.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        NSLayoutConstraint.activate([
            nicknameLabel.centerYAnchor.constraint(equalTo: userView.centerYAnchor),
            nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15)
        ])
        
        NSLayoutConstraint.activate([
            blockedButton.centerYAnchor.constraint(equalTo: userView.centerYAnchor),
            blockedButton.trailingAnchor.constraint(equalTo: userView.trailingAnchor, constant: -10),
            blockedButton.widthAnchor.constraint(equalToConstant: 80),
            blockedButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configureData(user: UserResponseDTO) {
        configureImage(url: user.profileImageURL)
        nicknameLabel.text = user.nickname
    }
    
    func configureImage(url: String) {
        Task {
            do {
                let data = try await APIProvider.shared.request(from: url)
                profileImageView.image = UIImage(data: data)
            } catch let error {
                dump(error)
            }
        }
    }
    
}

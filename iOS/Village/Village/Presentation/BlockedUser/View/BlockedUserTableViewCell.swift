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
        imageView.setLayer(borderWidth: 0, cornerRadius: 4)
        imageView.clipsToBounds = true
        
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
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(nicknameLabel)
        self.contentView.addSubview(blockedButton)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 36),
            profileImageView.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        NSLayoutConstraint.activate([
            nicknameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 25)
        ])
        
        NSLayoutConstraint.activate([
            blockedButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            blockedButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            blockedButton.widthAnchor.constraint(equalToConstant: 80),
            blockedButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configureData(user: BlockedUserDTO) {
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

//
//  ProfileTableViewCell.swift
//  Village
//
//  Created by 조성민 on 12/14/23.
//

import UIKit
import Combine

final class ProfileTableViewCell: UITableViewCell {
    
    var editProfileSubject = PassthroughSubject<Void, Never>()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .primary500
        imageView.setLayer(borderWidth: 0, cornerRadius: 16)
        imageView.backgroundColor = .primary100
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let profileInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        
        return stackView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        return label
    }()
    
    private let hashIDLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    override func prepareForReuse() {
        profileImageView.image = nil
        nicknameLabel.text = nil
        hashIDLabel.text = nil
        editProfileSubject = PassthroughSubject<Void, Never>()
    }
    
    private lazy var profileEditButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "프로필 수정"
        configuration.titleAlignment = .center
        configuration.baseForegroundColor = .label
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(profileEditButtonTapped), for: .touchUpInside)
        button.configuration = configuration
        button.contentHorizontalAlignment = .leading
        button.setLayer(borderWidth: 0)
        button.backgroundColor = .systemGray5
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureData(profileInfo: ProfileInfo) {
        guard let data = profileInfo.profileImage,
              let image = UIImage(data: data) else { return }
        self.profileImageView.image = image
        self.nicknameLabel.text = profileInfo.nickname
        guard let userID = JWTManager.shared.currentUserID else { return }
        self.hashIDLabel.text = "#" + userID
    }
    
    @objc private func profileEditButtonTapped() {
        editProfileSubject.send()
    }
    
    private func setUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(profileInfoStackView)
        profileInfoStackView.addArrangedSubview(nicknameLabel)
        profileInfoStackView.setCustomSpacing(2, after: nicknameLabel)
        profileInfoStackView.addArrangedSubview(hashIDLabel)
        profileInfoStackView.setCustomSpacing(6, after: hashIDLabel)
        profileInfoStackView.addArrangedSubview(profileEditButton)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 96),
            profileImageView.heightAnchor.constraint(equalToConstant: 96)
        ])
        
        NSLayoutConstraint.activate([
            profileInfoStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            profileInfoStackView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
}

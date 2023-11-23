//
//  UserInfoView.swift
//  Village
//
//  Created by 정상윤 on 11/23/23.
//

import UIKit

final class UserInfoView: UIView {
    
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.setLayer(borderColor: .grey100, cornerRadius: 26)
        return imageView
    }()
    
    private var nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        setLayoutConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("Should not be called")
    }
    
    func setContent(imageURL: String, nickname: String) {
        Task {
            do {
                let data = try await NetworkService.loadData(from: imageURL)
                profileImageView.image = UIImage(data: data)
            } catch let error {
                dump(error)
            }
        }
        nicknameLabel.text = nickname
    }

}

private extension UserInfoView {
    
    func configureUI() {
        addSubview(profileImageView)
        addSubview(nicknameLabel)
    }
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 70)
        ])
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            nicknameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
}

//
//  ProfileImageView.swift
//  Village
//
//  Created by 정상윤 on 11/27/23.
//

import UIKit

final class ProfileImageView: UIView {

    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray4
        imageView.tintColor = .systemGray6
        imageView.image = UIImage(systemName: ImageSystemName.personFill.rawValue)
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .secondarySystemFill.withAlphaComponent(1)
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: ImageSystemName.cameraCircleFill.rawValue)
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        setLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("should not be called")
    }
    
    func setProfile(image: UIImage) {
        profileImageView.image = image
    }

}

private extension ProfileImageView {
    
    func configureUI() {
        addSubview(profileImageView)
        addSubview(photoImageView)
    }
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            profileImageView.topAnchor.constraint(equalTo: topAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            photoImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 30),
            photoImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
}

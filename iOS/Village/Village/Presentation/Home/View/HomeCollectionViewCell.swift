//
//  HomeCollectionViewCell.swift
//  Village
//
//  Created by 박동재 on 2023/11/15.
//

import UIKit

final class HomeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HomeCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: ImageSystemName.photo.rawValue)
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .primary100
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.text = "10000원"
        
        return label
    }()
    
    let accessoryView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: ImageSystemName.chevronRight.rawValue)
        
        return imageView
    }()
    
    func setUI() {
        self.addSubview(postImageView)
        self.addSubview(titleLabel)
        self.addSubview(priceLabel)
        self.addSubview(accessoryView)
        configureConstraints()
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            postImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            postImageView.widthAnchor.constraint(equalToConstant: 80),
            postImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 25),
            titleLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            accessoryView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            accessoryView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ])
    }
}

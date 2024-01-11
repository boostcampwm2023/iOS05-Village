//
//  RentPostSummaryView.swift
//  Village
//
//  Created by 박동재 on 2023/11/20.
//

import UIKit

final class RentPostSummaryView: UIView {
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let postTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        
        return label
    }()
    
    let postPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        
        return label
    }()
    
    let postAccessoryView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: ImageSystemName.chevronRight.rawValue)
        imageView.tintColor = .primary500
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    func configureData(post: PostDetail) {
        postTitleLabel.text = post.title
        setPrice(price: post.price)
        configureImageView(imageURL: post.images.first)
    }
    
    private func configureImageView(imageURL: String?) {
        guard let imageURL = imageURL else {
            postImageView.image = UIImage(systemName: ImageSystemName.photo.rawValue)?
                .withTintColor(.primary500, renderingMode: .alwaysOriginal)
            postImageView.backgroundColor = .primary100
            return
        }
        
        Task {
            do {
                let data = try await APIProvider.shared.request(from: imageURL)
                guard let image = UIImage(data: data) else {
                    postImageView.image = UIImage(systemName: ImageSystemName.photo.rawValue)?
                        .withTintColor(.primary500, renderingMode: .alwaysOriginal)
                    postImageView.backgroundColor = .primary100
                    return
                }
                postImageView.image = image
            } catch {
                dump(error)
            }
        }
    }
    
    private func setUI() {
        addSubview(postImageView)
        addSubview(postTitleLabel)
        addSubview(postPriceLabel)
        addSubview(postAccessoryView)
        
        configureConstraints()
    }
    
    private func configureConstraints() {
        
        NSLayoutConstraint.activate([
            postImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            postImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            postImageView.widthAnchor.constraint(equalToConstant: 80),
            postImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            postTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -15),
            postTitleLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 20),
            postTitleLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        NSLayoutConstraint.activate([
            postPriceLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 15),
            postPriceLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            postAccessoryView.centerYAnchor.constraint(equalTo: centerYAnchor),
            postAccessoryView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    func setPrice(price: Int?) {
        var priceText = ""
        if let price = price {
            priceText = price.priceText()
        }
        postPriceLabel.text = priceText.isEmpty ? "" : "\(priceText)원"
    }
    
}

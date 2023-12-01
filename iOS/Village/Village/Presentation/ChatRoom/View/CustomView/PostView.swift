//
//  PostView.swift
//  Village
//
//  Created by 박동재 on 2023/11/27.
//

import UIKit

final class PostView: UIView {
    
    let postView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        
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
        label.font = .systemFont(ofSize: 14, weight: .bold)
        
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
    
    private func setUI() {
        postView.addSubview(postImageView)
        postView.addSubview(postTitleLabel)
        postView.addSubview(postPriceLabel)
        postView.addSubview(postAccessoryView)
        self.addSubview(postView)
        
        configureConstraints()
    }
    
    func setContent(url: String, title: String, price: String) {
        setImageView(url: url)
        postTitleLabel.text = title
        postPriceLabel.text = price
    }
    
    private func setImageView(url: String) {
        Task {
            do {
                let data = try await APIProvider.shared.request(from: url)
                postImageView.image = UIImage(data: data)
            } catch let error {
                dump(error)
            }
        }
    }
    
    private func configureConstraints() {
        
        NSLayoutConstraint.activate([
            postView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            postView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            postView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            postView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: postView.topAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: postView.leadingAnchor, constant: 20),
            postImageView.widthAnchor.constraint(equalToConstant: 60),
            postImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            postTitleLabel.topAnchor.constraint(equalTo: postView.topAnchor, constant: 15),
            postTitleLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 20),
            postTitleLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        NSLayoutConstraint.activate([
            postPriceLabel.topAnchor.constraint(equalTo: postTitleLabel.bottomAnchor, constant: 10),
            postPriceLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            postAccessoryView.topAnchor.constraint(equalTo: postView.topAnchor, constant: 29),
            postAccessoryView.leadingAnchor.constraint(equalTo: postTitleLabel.trailingAnchor, constant: 50)
        ])
    }
}

//
//  HomeCollectionViewCell.swift
//  Village
//
//  Created by 박동재 on 2023/11/15.
//

import UIKit

final class HomeCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let postSummaryView: RentPostSummaryView = {
        let view = RentPostSummaryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private func setUI() {
        addSubview(postSummaryView)
        setLayoutConstraints()
    }
    
    func configureData(post: PostListItem) {
        postSummaryView.postTitleLabel.text = post.title
        let price = post.price.map(String.init) ?? ""
        postSummaryView.postPriceLabel.text = price != "" ? "\(price)원" : ""
    }
    
    func configureImage(image: UIImage?) {
        if image != nil {
            postSummaryView.postImageView.image = image
            postSummaryView.postImageView.backgroundColor = nil
        } else {
            postSummaryView.postImageView.image = UIImage(systemName: ImageSystemName.photo.rawValue)?
                .withTintColor(.primary500, renderingMode: .alwaysOriginal)
            postSummaryView.postImageView.backgroundColor = .primary100
        }
    }
    
    private func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            postSummaryView.topAnchor.constraint(equalTo: topAnchor),
            postSummaryView.leadingAnchor.constraint(equalTo: leadingAnchor),
            postSummaryView.trailingAnchor.constraint(equalTo: trailingAnchor),
            postSummaryView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}

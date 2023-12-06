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
        super.init(coder: coder)
        setUI()
    }
    
    let postSummaryView = RentPostSummaryView()
    
    private func setUI() {
        self.addSubview(postSummaryView)
    }
    
    func configureData(post: PostListItem) {
        postSummaryView.postTitleLabel.text = post.title
        let price = post.price.map(String.init) ?? ""
        postSummaryView.postPriceLabel.text = price != "" ? "\(price)원" : ""
    }
    
    func configureImage(image: UIImage?) {
        if image != nil {
            postSummaryView.postImageView.image = image
        } else {
            postSummaryView.postImageView.image = UIImage(systemName: ImageSystemName.photo.rawValue)?
                .withTintColor(.primary500, renderingMode: .alwaysOriginal)
            postSummaryView.postImageView.backgroundColor = .primary100
        }
    }
}

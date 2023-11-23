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
        setUI()
    }
    
    let postSummaryView = PostSummaryView()
    
    private func setUI() {
        self.addSubview(postSummaryView)
    }
    
    func configureData(post: PostResponseDTO) {
        postSummaryView.postTitleLabel.text = post.title
        let price = post.price.map(String.init) ?? ""
        postSummaryView.postPriceLabel.text = price != "" ? "\(price)원" : ""
    }
    
    func configureImage(image: UIImage?) {
        if image != nil {
            postSummaryView.postImageView.image = image
        } else {
            postSummaryView.postImageView.image = UIImage(systemName: ImageSystemName.photo.rawValue)
            postSummaryView.postImageView.backgroundColor = .primary100
        }
    }
}

//
//  RentPostTableViewCell.swift
//  Village
//
//  Created by 조성민 on 12/5/23.
//

import UIKit

final class RentPostTableViewCell: UITableViewCell {

    private let postSummaryView: RentPostSummaryView = {
        let view = RentPostSummaryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(postSummaryView)
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        postSummaryView.postImageView.image = nil
        postSummaryView.postTitleLabel.text = nil
        postSummaryView.postPriceLabel.text = nil
    }
    
    func configureData(post: PostListItem) {
        postSummaryView.postTitleLabel.text = post.title
        postSummaryView.setPrice(price: post.price)
        configureImageView(imageURL: post.thumbnailURL)
    }
    
    private func configureImageView(imageURL: String?) {
        guard let imageURL = imageURL else {
            postSummaryView.postImageView.image = UIImage(systemName: ImageSystemName.photo.rawValue)?
                .withTintColor(.primary500, renderingMode: .alwaysOriginal)
            postSummaryView.postImageView.backgroundColor = .primary100
            return
        }
        
        Task {
            do {
                let data = try await APIProvider.shared.request(from: imageURL)
                guard let image = UIImage(data: data) else {
                    postSummaryView.postImageView.image = UIImage(systemName: ImageSystemName.photo.rawValue)?
                        .withTintColor(.primary500, renderingMode: .alwaysOriginal)
                    postSummaryView.postImageView.backgroundColor = .primary100
                    return
                }
                postSummaryView.postImageView.backgroundColor = nil
                postSummaryView.postImageView.image = image
            } catch {
                dump(error)
            }
        }
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            postSummaryView.topAnchor.constraint(equalTo: contentView.topAnchor),
            postSummaryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            postSummaryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            postSummaryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
}

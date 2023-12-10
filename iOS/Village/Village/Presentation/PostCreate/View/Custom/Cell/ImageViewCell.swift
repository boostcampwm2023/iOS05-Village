//
//  ImageViewCell.swift
//  Village
//
//  Created by 정상윤 on 12/7/23.
//

import UIKit
import Combine

final class ImageViewCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 5
        
        return view
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        addSubview(imageView)
        setLayoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    func setImage(data: Data) {
        imageView.image = UIImage(data: data)
    }
    
}

private extension ImageViewCell {
    
    func setLayoutConstraint() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}

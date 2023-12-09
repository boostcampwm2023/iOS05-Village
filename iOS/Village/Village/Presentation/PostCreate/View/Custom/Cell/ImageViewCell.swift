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
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var deleteButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: ImageSystemName.xmark.rawValue)?.resize(newWidth: 15, newHeight: 13)
        configuration.baseForegroundColor = .black
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .grey100
        button.layer.cornerRadius = 10
        
        return button
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        addSubview(imageView)
        addSubview(deleteButton)
        setLayoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        deleteButton.removeTarget(nil, action: nil, for: .touchUpInside)
    }
    
    func configure(imageData: Data, deleteAction: UIAction) {
        imageView.image = UIImage(data: imageData)
        deleteButton.addAction(deleteAction, for: .touchUpInside)
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
        
        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor),
            deleteButton.centerXAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            deleteButton.centerYAnchor.constraint(equalTo: topAnchor, constant: 2)
        ])
    }
    
}

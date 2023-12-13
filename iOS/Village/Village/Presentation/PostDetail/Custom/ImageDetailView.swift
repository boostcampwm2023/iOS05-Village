//
//  ImageDetailView.swift
//  Village
//
//  Created by 정상윤 on 12/13/23.
//

import UIKit

final class ImageDetailView: UIView {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .systemBackground
        
        return view
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: ImageSystemName.xmark.rawValue), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        
        return button
    }()
    
    init(imageData: Data) {
        super.init(frame: .zero)
        imageView.image = UIImage(data: imageData)
        
        addSubview(imageView)
        addSubview(dismissButton)
        setLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func dismissAction() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.alpha = 0
        })
        removeFromSuperview()
    }
    
    private func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            dismissButton.widthAnchor.constraint(equalToConstant: 30),
            dismissButton.heightAnchor.constraint(equalToConstant: 30),
            dismissButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            dismissButton.topAnchor.constraint(equalTo: topAnchor, constant: 5)
        ])
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}

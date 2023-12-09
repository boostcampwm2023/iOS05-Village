//
//  CameraButtonCell.swift
//  Village
//
//  Created by 정상윤 on 12/7/23.
//

import UIKit

final class CameraButtonCell: UICollectionViewCell {
    
    private lazy var cameraButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePlacement = .top
        configuration.image = UIImage(systemName: ImageSystemName.cameraFill.rawValue)
        configuration.baseForegroundColor = .grey800
        configuration.imagePadding = 5
        
        let button = UIButton(configuration: configuration)
        button.setLayer(cornerRadius: 5)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(cameraButton)
        setLayoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImageCount(_ count: Int) {
        let attributedTitle = NSAttributedString(
            string: "\(count)/\(Constant.maxImageCount)",
            attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .light)]
        )
        cameraButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func addButtonAction(_ action: UIAction) {
        cameraButton.addAction(action, for: .touchUpInside)
    }
    
}

private extension CameraButtonCell {
    
    func setLayoutConstraint() {
        NSLayoutConstraint.activate([
            cameraButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            cameraButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            cameraButton.topAnchor.constraint(equalTo: topAnchor),
            cameraButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}

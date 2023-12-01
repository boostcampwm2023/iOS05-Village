//
//  FloatingButton.swift
//  Village
//
//  Created by 정상윤 on 11/14/23.
//

import UIKit
import Combine

final class FloatingButton: UIView {
    
    @Published var isActive = false {
        willSet {
            switch newValue {
            case true:
                activate()
            case false:
                deactivate()
            }
        }
    }
    
    private var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .primary500
        return button
    }()
    
    init(imageSystemName: ImageSystemName = .plus, frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 32.5
        self.clipsToBounds = true
        
        configureButton(imageSystemName: imageSystemName)
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

private extension FloatingButton {
    
    func activate() {
        button.backgroundColor = .grey800

        UIView.transition(with: self, duration: 0.2) {
            self.transform = CGAffineTransform(rotationAngle: .pi/4)
        }
    }
    
    func deactivate() {
        button.backgroundColor = .primary500

        UIView.transition(with: self, duration: 0.2) {
            self.transform = CGAffineTransform(rotationAngle: 0)
        }
    }
    
    func configureButton(imageSystemName: ImageSystemName) {
        self.addSubview(button)
        
        setButtonImage(imageSystemName: imageSystemName)
        setButtonAction()
        setButtonLayoutConstraint()
    }
    
    func setButtonImage(imageSystemName: ImageSystemName) {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let plusImage = UIImage(systemName: imageSystemName.rawValue, withConfiguration: config)
        
        button.backgroundColor = .primary500
        button.tintColor = .white
        button.setImage(plusImage, for: .normal)
    }
    
    func setButtonAction() {
        let action = UIAction { [weak self] _ in
            self?.isActive.toggle()
        }
        button.addAction(action, for: .touchUpInside)
    }
    
    func setButtonLayoutConstraint() {
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            button.topAnchor.constraint(equalTo: self.topAnchor),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

}

//
//  FloatingButton.swift
//  Village
//
//  Created by 정상윤 on 11/14/23.
//

import UIKit
import Combine

final class FloatingButton: UIButton {
    
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
    
    init(imageSystemName: ImageSystemName = .plus, frame: CGRect) {
        super.init(frame: frame)
        
        let action = UIAction { [weak self] _ in
            self?.isActive.toggle()
        }
        addAction(action, for: .touchUpInside)
        
        self.layer.cornerRadius = 32.5
        self.backgroundColor = .primary500
        self.tintColor = .white
        
        setImage(imageSystemName: imageSystemName)
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

// MARK: - UI

private extension FloatingButton {
    
    func activate() {
        self.backgroundColor = .grey800

        UIView.transition(with: self, duration: 0.2) {
            self.transform = CGAffineTransform(rotationAngle: .pi/4)
        }
    }
    
    func deactivate() {
        self.backgroundColor = .primary500

        UIView.transition(with: self, duration: 0.2) {
            self.transform = CGAffineTransform(rotationAngle: 0)
        }
    }
    
    func setImage(imageSystemName: ImageSystemName) {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let plusImage = UIImage(systemName: imageSystemName.rawValue, withConfiguration: config)
        
        self.setImage(plusImage, for: .normal)
    }

}

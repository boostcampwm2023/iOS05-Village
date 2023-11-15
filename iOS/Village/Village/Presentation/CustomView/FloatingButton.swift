//
//  FloatingButton.swift
//  Village
//
//  Created by 정상윤 on 11/14/23.
//

import UIKit
import Combine

final class FloatingButton: UIButton {
    
    @Published var toggle = false {
        willSet {
            switch newValue {
            case true:
                toggleOn()
            case false:
                toggleOff()
            }
        }
    }
    
    init(imageName: String = "plus", frame: CGRect) {
        super.init(frame: frame)
        
        addAction(.init { [weak self] _ in self?.toggle.toggle()}, for: .touchUpInside)
        
        self.layer.cornerRadius = 32.5
        self.backgroundColor = .primary500
        self.tintColor = .white
        
        setImage(imageName: imageName)
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
    
    func toggleOn() {
        self.backgroundColor = .grey800

        UIView.transition(with: self, duration: 0.2) {
            self.transform = CGAffineTransform(rotationAngle: .pi/4)
        }
    }
    
    func toggleOff() {
        self.backgroundColor = .primary500

        UIView.transition(with: self, duration: 0.2) {
            self.transform = CGAffineTransform(rotationAngle: 0)
        }
    }
    
    func setImage(imageName: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let plusImage = UIImage(systemName: imageName, withConfiguration: config)
        
        self.setImage(plusImage, for: .normal)
    }

}

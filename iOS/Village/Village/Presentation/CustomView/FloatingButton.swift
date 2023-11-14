//
//  FloatingButton.swift
//  Village
//
//  Created by 정상윤 on 11/14/23.
//

import UIKit

final class FloatingButton: UIButton {
    
    private var toggle = false {
        didSet {
            updateUI()
        }
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 65, height: 65))
        
        self.layer.cornerRadius = 32.5
        self.backgroundColor = .primary500
        self.tintColor = .white
        
        setImage()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func trigger() {
        toggle.toggle()
    }
    
}

// MARK: - UI

private extension FloatingButton {
    
    func updateUI() {
        switch toggle {
        case true:
            toggleOn()
        case false:
            toggleOff()
        }
    }
    
    func toggleOn() {
        self.backgroundColor = .grey800
        
        UIView.transition(with: self, duration: 0.3) {
            self.transform = .init(rotationAngle: .pi/4)
        }
    }
    
    func toggleOff() {
        self.backgroundColor = .primary500
        
        UIView.transition(with: self, duration: 0.3) {
            self.transform = .init(rotationAngle: 0)
        }
    }
    
    func setImage() {
        let imageName = "plus"
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let plusImage = UIImage(systemName: imageName, withConfiguration: config)
        
        self.setImage(plusImage, for: .normal)
    }
}

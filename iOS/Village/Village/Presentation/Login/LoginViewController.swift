//
//  LoginViewController.swift
//  Village
//
//  Created by 정상윤 on 11/27/23.
//

import UIKit
import AuthenticationServices

final class LoginViewController: UIViewController {
    
    private lazy var appLogoImageView: UIImageView = {
        let image = UIImageView(image: .loginLogo)
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    private lazy var appleAuthorizationButton: ASAuthorizationAppleIDButton = {
        var button: ASAuthorizationAppleIDButton
        if traitCollection.userInterfaceStyle == .dark {
            button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn,
                                                  authorizationButtonStyle: .white)
        } else {
            button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn,
                                                  authorizationButtonStyle: .black)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        setLayoutConstraints()
    }

}

private extension LoginViewController {
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(appLogoImageView)
        view.addSubview(appleAuthorizationButton)
    }
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            appLogoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            appLogoImageView.heightAnchor.constraint(equalTo: appLogoImageView.widthAnchor),
            appLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            .init(item: appLogoImageView, attribute: .centerY,
                  relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.8, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            appleAuthorizationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleAuthorizationButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            appleAuthorizationButton.heightAnchor.constraint(equalToConstant: 44),
            .init(item: appleAuthorizationButton, attribute: .centerY,
                  relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.35, constant: 0)
        ])
    }
    
}

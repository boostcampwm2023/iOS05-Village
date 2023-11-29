//
//  LoginViewController.swift
//  Village
//
//  Created by 정상윤 on 11/27/23.
//

import UIKit
import Combine
import AuthenticationServices

final class LoginViewController: UIViewController {
    
    typealias ViewModel = LoginViewModel
    typealias Input = ViewModel.Input
    
    private let viewModel = ViewModel()
    private var cancellableBag = Set<AnyCancellable>()
    
    private var identityToken = PassthroughSubject<Data, Never>()
    private var authorizationCode = PassthroughSubject<Data, Never>()
    
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
        button.addTarget(self, action: #selector(appleAuthorizationButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        setLayoutConstraints()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.transform(input: Input(identityToken: identityToken.eraseToAnyPublisher(),
                                         authorizationCode: authorizationCode.eraseToAnyPublisher()))
        .authenticationToken
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                dump(error)
            default:
                break
            }
        }, receiveValue: { [weak self] _ in
            self?.notifyLoginSucceed()
        })
        .store(in: &cancellableBag)
    }
    
    @objc
    private func appleAuthorizationButtonTapped() {
        let request = createRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func createRequest() -> ASAuthorizationRequest {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email]
        return request
    }
    
    private func notifyLoginSucceed() {
        NotificationCenter.default.post(Notification(name: .loginSucceed))
    }

}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let token = credential.identityToken,
              let code = credential.authorizationCode else { return }
        
        identityToken.send(token)
        authorizationCode.send(code)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        dump("Apple Login Failed: \(error)")
    }
    
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
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

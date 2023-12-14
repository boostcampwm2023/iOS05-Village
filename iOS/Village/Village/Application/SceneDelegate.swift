//
//  SceneDelegate.swift
//  Village
//
//  Created by 조성민 on 11/8/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        addObservers()
        
        window = UIWindow(windowScene: windowScene)
        autoLogin()
        window?.makeKeyAndVisible()
    }
    
    private func addObservers() {
        observeLoginSucceedEvent()
        observeShouldLoginEvent()
    }
    
    private func observeLoginSucceedEvent() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rootViewControllerToTabBarController),
                                               name: .loginSucceed,
                                               object: nil
        )
    }
    
    private func autoLogin() {
            guard let accessToken = JWTManager.shared.get()?.accessToken else {
                window?.rootViewController = LoginViewController()
                return
            }
            let endpoint = APIEndPoints.tokenExpire(accessToken: accessToken)
            Task {
                do {
                    try await APIProvider.shared.request(with: endpoint)
                    
                    window?.rootViewController = AppTabBarController()
                } catch {
                    window?.rootViewController = LoginViewController()
                }
            }
        }
    
    private func observeShouldLoginEvent() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rootViewControllerToLoginViewController),
                                               name: .shouldLogin,
                                               object: nil)
    }
    
    @objc
    private func rootViewControllerToTabBarController() {
        DispatchQueue.main.async { [weak self] in
            self?.window?.rootViewController = AppTabBarController()
        }
    }
    
    @objc
    private func rootViewControllerToLoginViewController() {
        DispatchQueue.main.async { [weak self] in
            self?.window?.rootViewController = LoginViewController()
        }
    }

}

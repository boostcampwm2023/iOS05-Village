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
        
        observeLoginSucceedEvent()
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = LoginViewController()
        window?.makeKeyAndVisible()
    }
    
    private func observeLoginSucceedEvent() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rootViewControllerToTabBarController),
                                               name: .loginSucceed,
                                               object: nil
        )
    }
    
    @objc
    private func rootViewControllerToTabBarController() {
        window?.rootViewController = AppTabBarController()
    }

}

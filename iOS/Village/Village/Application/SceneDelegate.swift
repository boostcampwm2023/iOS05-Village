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
    
    private func observeShouldLoginEvent() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rootViewControllerToLoginViewController),
                                               name: .shouldLogin,
                                               object: nil)
    }
    
    private func autoLogin() {
        guard let token = JWTManager.shared.get() else { return }
        let endpoint = APIEndPoints.tokenExpire(accessToken: token.refreshToken)
        Task {
            do {
                try await APIProvider.shared.request(with: endpoint)
                window?.rootViewController = AppTabBarController()
            } catch let error {
                if let err = error as? NetworkError {
                    switch err {
                    case .serverError(.forbidden):
                        dump("forbidden came!")
                        refreshToken()
                    case .serverError(.serverError):
                        dump("서버 에러가 발생했습니다! 다시 로그인해주세요.")
                    default:
                        dump(error)
                    }
                }
                window?.rootViewController = LoginViewController()
                return
            }
        }
    }
    
    private func refreshToken() {
        guard let refreshToken = JWTManager.shared.get()?.refreshToken else { return }
        
        let endpoint = APIEndPoints.tokenRefresh(refreshToken: refreshToken)
        Task {
            do {
                guard let token = try await APIProvider.shared.request(with: endpoint) else { return }
                try JWTManager.shared.update(token: token)
                window?.rootViewController = AppTabBarController()
            } catch let error {
                if let err = error as? NetworkError {
                    switch err {
                    case .serverError(.forbidden):
                        dump("토큰이 만료됐습니다! 다시 로그인해주세요.")
                        NotificationCenter.default.post(Notification(name: .shouldLogin))
                    default:
                        dump(error)
                    }
                }
            }
        }
    }
    
    @objc
    private func rootViewControllerToTabBarController() {
        window?.rootViewController = AppTabBarController()
    }
    
    @objc
    private func rootViewControllerToLoginViewController() {
        window?.rootViewController = LoginViewController()
    }

}

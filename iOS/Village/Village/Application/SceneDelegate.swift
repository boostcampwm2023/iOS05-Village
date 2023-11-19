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
        
        window = UIWindow(windowScene: windowScene)
        
        let tapBarController = UITabBarController()
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        let chatViewController = UINavigationController(rootViewController: ChatViewController())
        let myPageViewController = UINavigationController(rootViewController: MyPageViewController())
        
        tapBarController.setViewControllers(
            [homeViewController, chatViewController, myPageViewController],
            animated: true
        )
        
        if let items = tapBarController.tabBar.items {
            items[0].selectedImage = UIImage(systemName: ImageSystemName.houseFill.rawValue)
            items[0].image = UIImage(systemName: ImageSystemName.house.rawValue)
            items[0].title = "홈"
            
            items[1].selectedImage = UIImage(systemName: ImageSystemName.messageFill.rawValue)
            items[1].image = UIImage(systemName: ImageSystemName.message.rawValue)
            items[1].title = "채팅"
            
            items[2].selectedImage = UIImage(systemName: ImageSystemName.personFill.rawValue)
            items[2].image = UIImage(systemName: ImageSystemName.person.rawValue)
            items[2].title = "내 정보"
        }
        
        window?.rootViewController = tapBarController
        window?.makeKeyAndVisible()
    }

}

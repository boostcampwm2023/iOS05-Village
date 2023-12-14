//
//  AppTabBarController.swift
//  Village
//
//  Created by 정상윤 on 11/27/23.
//

import UIKit

final class AppTabBarController: UITabBarController {
    
    private let homeViewController = UINavigationController(
        rootViewController: HomeViewController()
    )
    private let chatListViewController = UINavigationController(
        rootViewController: ChatListViewController()
    )
    private let myPageViewController = UINavigationController(
        rootViewController: MyPageViewController(viewModel: MyPageViewModel())
    )
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setViewControllers()
        configureTabBarItems()
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            let endpoint = APIEndPoints.getAllRead()

            Task {
                do {
                    guard let data = try await APIProvider.shared.request(with: endpoint) else { return }
                    if data.allRead == true {
                        self?.tabBar.items?[1].badgeValue = nil
                    } else {
                        self?.tabBar.items?[1].badgeValue = "!"
                    }
                } catch {
                    dump(error)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
    }
    
    private func setup() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        tabBar.scrollEdgeAppearance = appearance
        view.backgroundColor = .systemBackground
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .primary500
        tabBar.unselectedItemTintColor = .primary500
    }
    
    private func setViewControllers() {
        homeViewController.navigationBar.isTranslucent = false
        homeViewController.navigationBar.backgroundColor = .systemBackground
        chatListViewController.navigationBar.isTranslucent = false
        chatListViewController.navigationBar.backgroundColor = .systemBackground
        myPageViewController.navigationBar.isTranslucent = false
        myPageViewController.navigationBar.backgroundColor = .systemBackground
        setViewControllers(
            [homeViewController, chatListViewController, myPageViewController],
            animated: true
        )
    }
    
    private func configureTabBarItems() {
        if let items = tabBar.items {
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
    }
    
}

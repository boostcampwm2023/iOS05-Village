//
//  MyPageViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/18.
//

import UIKit
import Combine

final class MyPageViewController: UIViewController {
    
    typealias ViewModel = MyPageViewModel
    typealias Input = ViewModel.Input
    
    private let viewModel: ViewModel
    private var cancellableBag: Set<AnyCancellable> = []
    
    private let logoutSubject = PassthroughSubject<Void, Never>()
    private let deleteAccountSubject = PassthroughSubject<Void, Never>()
    private let editProfileSubject = PassthroughSubject<Void, Never>()
    private let refreshSubject = PassthroughSubject<Void, Never>()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.register(MyPageTableViewCell.self, forCellReuseIdentifier: MyPageTableViewCell.identifier)
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationUI()
        setUI()
        setConstraints()
        bindViewModel()
        view.backgroundColor = .systemBackground
        refreshSubject.send()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshSubject.send()
    }
    
}

private extension MyPageViewController {
    
    func setNavigationUI() {
        let titleLabel = UILabel()
        titleLabel.setTitle("마이페이지")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.backButtonDisplayMode = .minimal
    }
    
    func setUI() {
        view.addSubview(tableView)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0)
        ])
    }
    
    func bindViewModel() {
        let output = viewModel.transform(input: Input(
            logoutSubject: logoutSubject.eraseToAnyPublisher(),
            deleteAccountSubject: deleteAccountSubject.eraseToAnyPublisher(),
            editProfileSubject: editProfileSubject.eraseToAnyPublisher(),
            refreshInputSubject: refreshSubject.eraseToAnyPublisher()
        ))
        handleLogout(output: output)
        handleDeleteAccount(output: output)
        handleEditProfile(output: output)
        handleRefresh(output: output)
    }
    
    func handleLogout(output: ViewModel.Output) {
        output.logoutSucceed
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump("Failed logout: \(error)")
                }
            } receiveValue: {
                NotificationCenter.default.post(Notification(name: .shouldLogin))
            }
            .store(in: &cancellableBag)
    }
    
    func handleDeleteAccount(output: ViewModel.Output) {
        output.deleteAccountSucceed
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump("Failed delete account: \(error)")
                }
            } receiveValue: {
                NotificationCenter.default.post(Notification(name: .shouldLogin))
            }
            .store(in: &cancellableBag)
        
    }
    
    func handleEditProfile(output: ViewModel.Output) {
        output.editProfileOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profileInfo in
                guard let self = self else { return }
                let nextVC = EditProfileViewController(viewModel: EditProfileViewModel(
                    profileInfo: profileInfo
                ))
                nextVC.hidesBottomBarWhenPushed = true
                nextVC.updateSuccessSubject
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] in
                        self?.refreshSubject.send()
                    }
                    .store(in: &self.cancellableBag)
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            .store(in: &cancellableBag)
    }
    
    func handleRefresh(output: ViewModel.Output) {
        output.refreshOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellableBag)
    }
    
}

private extension MyPageViewController {
    
    func myPostsButtonTapped() {
        let nextVC = MyPostsViewController(viewModel: MyPostsViewModel())
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func hiddenPostButtonTapped() {
        let nextVC = MyHiddenPostsViewController(viewModel: MyHiddenPostsViewModel())
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func blockedUsersButtonTapped() {
        let nextVC = BlockedUserViewController(viewModel: BlockedUsersViewModel())
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func logoutButtonTapped() {
        let alert = UIAlertController(title: "로그아웃", message: "정말 로그아웃하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .default, handler: { [weak self] _ in
            self?.logoutSubject.send()
        }))
        self.present(alert, animated: true)
    }
    
    func deleteAccountButtonTapped() {
        let alert = UIAlertController(title: "회원탈퇴", message: "회원탈퇴 시 모든 정보가 삭제됩니다!\n진행하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "탈퇴하기", style: .destructive, handler: { [weak self] _ in
            self?.deleteAccountSubject.send()
        }))
        self.present(alert, animated: true)
    }
    
}

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getTableViewContentCount(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileTableViewCell.identifier,
                for: indexPath
            ) as? ProfileTableViewCell {
                cell.editProfileSubject
                    .sink { [weak self] _ in
                        self?.editProfileSubject.send()
                    }
                    .store(in: &cancellableBag)
                guard let profileInfo = viewModel.getProfileInfo() else { return cell }
                cell.configureData(profileInfo: profileInfo)
                
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: MyPageTableViewCell.identifier,
                for: indexPath
            ) as? MyPageTableViewCell {
                cell.configureData(text: viewModel.getTableViewContent(section: indexPath.section, row: indexPath.row)
                )
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                myPostsButtonTapped()
            case 1:
                hiddenPostButtonTapped()
            case 2:
                blockedUsersButtonTapped()
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                logoutButtonTapped()
            case 1:
                deleteAccountButtonTapped()
            default:
                break
            }
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "내 활동"
        case 2:
            return "계정"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 100
        default:
            return 40
        }
    }
    
}

//
//  HomeViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/15.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    
    typealias RentPostDataSource = UITableViewDiffableDataSource<Section, PostListResponseDTO>
    typealias RequestPostDataSource = UITableViewDiffableDataSource<Section, PostListResponseDTO>
    
    typealias ViewModel = HomeViewModel
    typealias Input = ViewModel.Input
    
    private let reuseIdentifier = HomeCollectionViewCell.identifier
    
    private let needPostList = CurrentValueSubject<Bool, Never>(false)
    private let viewModel = ViewModel()
    
    private lazy var postSegmentedControl: PostSegmentedControl = {
        let control = PostSegmentedControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        
        return control
    }()
    
    private lazy var rentDataSoruce = RentPostDataSource(
        tableView: rentPostTableView,
        cellProvider: { [weak self] (tableView, indexPath, postDTO) in
            if let cell = tableView.dequeueReusableCell(withIdentifier: RentPostTableViewCell.identifier,
                                                        for: indexPath) as? RentPostTableViewCell {
                cell.configureData(post: postDTO)
                return cell
            }
    })
    
    private lazy var requestDataSource = RequestPostDataSource(
        tableView: requestPostTableView,
        cellProvider: { [weak self] (tableView, indexPath, postDTO) in
            if let cell = tableView.dequeueReusableCell(withIdentifier: RequestPostTableViewCell.identifier,
                                                        for: indexPath) as? RequestPostTableViewCell {
                cell.configureData(post: postDTO)
                return cell
            }
    })
    
    private lazy var rentPostTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100
        tableView.register(RentPostTableViewCell.self, forCellReuseIdentifier: RentPostTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.delegate = self
        
        return tableView
    }()
    
    private lazy var requestPostTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100
        tableView.register(RequestPostTableViewCell.self, forCellReuseIdentifier: RequestPostTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.delegate = self
        
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshPost), for: .valueChanged)
        
        return control
    }()
    
    private let floatingButton: FloatingButton = {
        let button = FloatingButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let menuView: MenuView = {
        let menu = MenuView()
        menu.isHidden = true
        menu.translatesAutoresizingMaskIntoConstraints = false
        
        return menu
    }()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshPost()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        floatingButton.isActive = false
    }
    
    private func setupUI() {
        setNavigationUI()
        setMenuUI()
        bindFloatingButton()
        
        view.addSubview(postSegmentedControl)
        view.addSubview(floatingButton)
        view.addSubview(menuView)
        setLayoutConstraint()
    }
    
    private func bindFloatingButton() {
        floatingButton.$isActive
            .sink(receiveValue: { [weak self] isActive in
                switch isActive {
                case true:
                    self?.menuView.fadeIn()
                case false:
                    self?.menuView.fadeOut()
                }
            })
            .store(in: &cancellableBag)
    }
    
    private func bindViewModel() {
        viewModel.transform(input: Input(needPostList: needPostList.eraseToAnyPublisher()))
            .postList
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            }, receiveValue: { [weak self] list in
                self?.appendData(postList: list)
            })
            .store(in: &cancellableBag)
    }
    
    private func setNavigationUI() {
        let titleLabel = UILabel()
        titleLabel.setTitle("홈")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.backButtonDisplayMode = .minimal
        let search = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(searchButtonTapped), symbolName: .magnifyingGlass
        )
        self.navigationItem.rightBarButtonItems = [search]
    }
    
    private func setMenuUI() {
        let useCase = PostCreateUseCase(postCreateRepository: PostCreateRepository())
        let presentPostRequestNC = UIAction(title: "대여 요청하기") { [weak self] _ in
            let requestViewModel = PostCreateViewModel(useCase: useCase, isRequest: true, isEdit: false, postID: nil)
            let postRequestVC = PostCreateViewController(viewModel: requestViewModel)
            let postRequestNC = UINavigationController(rootViewController: postRequestVC)
            postRequestNC.modalPresentationStyle = .fullScreen
            self?.present(postRequestNC, animated: true)
        }
        let presentPostRentNC = UIAction(title: "대여 등록하기") { [weak self] _ in
            let rentViewModel = PostCreateViewModel(useCase: useCase, isRequest: false, isEdit: false, postID: nil)
            let postRentVC = PostCreateViewController(viewModel: rentViewModel)
            let postRentNC = UINavigationController(rootViewController: postRentVC)
            postRentNC.modalPresentationStyle = .fullScreen
            self?.present(postRentNC, animated: true)
        }
        menuView.setMenuActions([presentPostRequestNC, presentPostRentNC])
    }
    
}

private extension HomeViewController {
    
    @objc func refreshPost() {
        initializeDataSource()
        needPostList.send(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    @objc func searchButtonTapped() {
        let nextVC = SearchViewController()
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
    private func setLayoutConstraint() {
        NSLayoutConstraint.activate([
            floatingButton.widthAnchor.constraint(equalToConstant: 65),
            floatingButton.heightAnchor.constraint(equalToConstant: 65),
            floatingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            menuView.widthAnchor.constraint(equalToConstant: 150),
            menuView.heightAnchor.constraint(equalToConstant: 100),
            menuView.trailingAnchor.constraint(equalTo: floatingButton.trailingAnchor, constant: 0),
            menuView.bottomAnchor.constraint(equalTo: floatingButton.topAnchor, constant: -15)
        ])
        
        NSLayoutConstraint.activate([
            postSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            postSegmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            postSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            postSegmentedControl.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: postSegmentedControl.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}

extension HomeViewController: UICollectionViewDelegate {
    
    enum Section {
        case main
    }
    
    private func initializeDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostListItem>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func appendData(postList: [PostListItem]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(postList, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let post = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let postDetailVC = PostDetailViewController(postID: post.postID)
        postDetailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > collectionView.contentSize.height - 1300 {
            needPostList.send(false)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        floatingButton.isActive = false
    }
    
}

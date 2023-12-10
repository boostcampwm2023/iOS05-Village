//
//  HomeViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/15.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    
    typealias PostDataSource = UITableViewDiffableDataSource<Section, PostListResponseDTO>
    typealias PostSnapshot = NSDiffableDataSourceSnapshot<Section, PostListResponseDTO>
    
    typealias ViewModel = HomeViewModel
    typealias Input = ViewModel.Input
    
    private let reuseIdentifier = HomeCollectionViewCell.identifier
    
    private var postType: PostType = .rent
    private let refresh = PassthroughSubject<PostType, Never>()
    private let pagination = PassthroughSubject<PostType, Never>()
    
    private let viewModel = ViewModel()
    
    private lazy var postSegmentedControl: PostSegmentedControl = {
        let control = PostSegmentedControl(items: ["대여글", "요청글"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(togglePostType), for: .valueChanged)
        
        return control
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.bounces = false
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        
        return view
    }()
    
    private lazy var containerView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fillEqually
        
        return view
    }()
    
    private lazy var rentDataSource = PostDataSource(
        tableView: rentPostTableView,
        cellProvider: { [weak self] (tableView, indexPath, postDTO) in
            if let cell = tableView.dequeueReusableCell(withIdentifier: RentPostTableViewCell.identifier,
                                                        for: indexPath) as? RentPostTableViewCell {
                cell.configureData(post: postDTO)
                return cell
            }
            return UITableViewCell()
    })
    
    private lazy var requestDataSource = PostDataSource(
        tableView: requestPostTableView,
        cellProvider: { [weak self] (tableView, indexPath, postDTO) in
            if let cell = tableView.dequeueReusableCell(withIdentifier: RequestPostTableViewCell.identifier,
                                                        for: indexPath) as? RequestPostTableViewCell {
                cell.configureData(post: postDTO)
                return cell
            }
            return UITableViewCell()
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
        generateDataSource()
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
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addArrangedSubview(rentPostTableView)
        containerView.addArrangedSubview(requestPostTableView)
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
        let input = Input(
            refresh: refresh.eraseToAnyPublisher(),
            pagination: pagination.eraseToAnyPublisher()
        )
        let output = viewModel.transform(input: input)
        handlePostList(output: output)
    }
    
    private func handlePostList(output: ViewModel.Output) {
        output.postList
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dump(error)
                }
            } receiveValue: { [weak self] postList in
                self?.appendPost(items: postList)
            }
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
        refresh.send(postType)
    }
    
    @objc func togglePostType() {
        postType = (postType == .rent) ? .request : .rent
        switch postType {
        case .rent:
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        case .request:
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.width, y: 0), animated: true)
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
            scrollView.topAnchor.constraint(equalTo: postSegmentedControl.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, multiplier: 2),
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])
    }

}

extension HomeViewController: UITableViewDelegate {
    
    enum Section {
        case main
    }
    
    private func generateDataSource() {
        var rentSnapshot = PostSnapshot()
        var requestSnapshot = PostSnapshot()
        
        rentSnapshot.appendSections([.main])
        requestSnapshot.appendSections([.main])
        
        rentDataSource.apply(rentSnapshot)
        requestDataSource.apply(requestSnapshot)
    }
    
    private func appendPost(items: [PostListResponseDTO]) {
        switch postType {
        case .rent:
            var snapshot = rentDataSource.snapshot()
            snapshot.appendItems(items)
            rentDataSource.apply(snapshot, animatingDifferences: false)
        case .request:
            var snapshot = requestDataSource.snapshot()
            snapshot.appendItems(items)
            requestDataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var postID: Int
        if tableView == rentPostTableView {
            guard let post = rentDataSource.itemIdentifier(for: indexPath) else { return }
            postID = post.postID
        } else {
            guard let post = requestDataSource.itemIdentifier(for: indexPath) else { return }
            postID = post.postID
        }
        
        let postDetailVC = PostDetailViewController(postID: postID)
        postDetailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(postDetailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch postType {
        case .rent:
            if scrollView.contentOffset.y > rentPostTableView.contentSize.height - 1300 {
                pagination.send(postType)
            }
        case .request:
            if scrollView.contentOffset.y > requestPostTableView.contentSize.height - 1300 {
                pagination.send(postType)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        floatingButton.isActive = false
    }
    
}

extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let index = Int(round(scrollView.contentOffset.x / view.frame.width))
//        if index != postSegmentedControl.selectedSegmentIndex {
//            postSegmentedControl.selectedSegmentIndex = index
//            togglePostType()
//        }
    }
    
}

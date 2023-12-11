//
//  HomeViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/15.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    
    typealias PostDataSource = UITableViewDiffableDataSource<Section, PostResponseDTO>
    typealias PostSnapshot = NSDiffableDataSourceSnapshot<Section, PostResponseDTO>
    
    typealias ViewModel = HomeViewModel
    typealias Input = ViewModel.Input
    
    private let reuseIdentifier = HomeCollectionViewCell.identifier
    
    private var postType: PostType = .rent
    private let refresh = CurrentValueSubject<PostType, Never>(.rent)
    private let pagination = PassthroughSubject<PostType, Never>()
    private var paginationFlag: Bool = true
    
    private let viewModel = ViewModel()
    
    private lazy var postSegmentedControl: PostSegmentedControl = {
        let control = PostSegmentedControl(items: ["대여글", "요청글"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(togglePostType), for: .valueChanged)
        
        return control
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var containerViewLeadingConstraint: NSLayoutConstraint = {
        containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0)
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
        let refreshControl = UIRefreshControl()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100
        tableView.register(RentPostTableViewCell.self, forCellReuseIdentifier: RentPostTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPost), for: .valueChanged)
        tableView.delegate = self
        
        return tableView
    }()
    
    private lazy var requestPostTableView: UITableView = {
        let tableView = UITableView()
        let refreshControl = UIRefreshControl()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100
        tableView.register(RequestPostTableViewCell.self, forCellReuseIdentifier: RequestPostTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPost), for: .valueChanged)
        tableView.delegate = self
        
        return tableView
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        floatingButton.isActive = false
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
        handleCreatedPost(output: output)
        handleDeletedPost(output: output)
        handleEditedPost(output: output)
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
                if postList.isEmpty {
                    self?.paginationFlag = false
                } else {
                    self?.paginationFlag = true
                }
                self?.appendPost(items: postList)
            }
            .store(in: &cancellableBag)
    }
    
    private func handleCreatedPost(output: ViewModel.Output) {
        output.createdPost
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshPost()
            }
            .store(in: &cancellableBag)
    }
    
    private func handleDeletedPost(output: ViewModel.Output) {
        output.deletedPost
            .receive(on: DispatchQueue.main)
            .sink { [weak self] postID in
                self?.deletePost(id: postID)
            }
            .store(in: &cancellableBag)
    }
    
    private func handleEditedPost(output: ViewModel.Output) {
        output.editedPost
            .receive(on: DispatchQueue.main)
            .sink { [weak self] post in
                self?.replacePost(item: post)
            }
            .store(in: &cancellableBag)
    }
    
}

@objc
private extension HomeViewController {
    
    func refreshPost() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            let tableView = (postType == .rent) ? rentPostTableView : requestPostTableView
            resetDataSource()
            tableView.refreshControl?.endRefreshing()
            refresh.send(postType)
        }
    }
    
    func togglePostType() {
        postType = (postType == .rent) ? .request : .rent
        
        switch postType {
        case .rent:
            containerViewLeadingConstraint.constant = 0
        case .request:
            containerViewLeadingConstraint.constant = -view.frame.width
        }
        
        if requestDataSource.snapshot().numberOfItems == 0 {
            refresh.send(postType)
        }
        
    }
    
    func searchButtonTapped() {
        let nextVC = SearchResultViewController()
        nextVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
}

private extension HomeViewController {
    
    func setupUI() {
        setNavigationUI()
        setMenuUI()
        bindFloatingButton()
        
        view.addSubview(postSegmentedControl)
        view.addSubview(containerView)
        containerView.addSubview(rentPostTableView)
        containerView.addSubview(requestPostTableView)
        view.addSubview(floatingButton)
        view.addSubview(menuView)
        setLayoutConstraint()
    }
    
    func setNavigationUI() {
        let titleLabel = UILabel()
        titleLabel.setTitle("홈")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.backButtonDisplayMode = .minimal
        let search = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(searchButtonTapped), symbolName: .magnifyingGlass
        )
        self.navigationItem.rightBarButtonItems = [search]
    }
    
    func setMenuUI() {
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
    
    func setLayoutConstraint() {
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
            containerViewLeadingConstraint,
            containerView.topAnchor.constraint(equalTo: postSegmentedControl.bottomAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2)
        ])
        
        NSLayoutConstraint.activate([
            rentPostTableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            rentPostTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            rentPostTableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            rentPostTableView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5)
        ])
        
        NSLayoutConstraint.activate([
            requestPostTableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            requestPostTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            requestPostTableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            requestPostTableView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5)
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
        
        rentDataSource.apply(rentSnapshot, animatingDifferences: false)
        requestDataSource.apply(requestSnapshot, animatingDifferences: false)
    }
    
    private func resetDataSource() {
        let dataSource = (postType == .rent) ? rentDataSource : requestDataSource
        var snapshot = PostSnapshot()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func replacePost(item: PostResponseDTO) {
        let dataSource = (postType == .rent) ? rentDataSource : requestDataSource
        var snapshot = dataSource.snapshot()
        guard let index = snapshot.indexOfItem(item) else { return }
        snapshot.deleteItems([item])
        if snapshot.numberOfItems == 0 {
            snapshot.appendItems([item])
        } else {
            snapshot.insertItems([item], beforeItem: snapshot.itemIdentifiers[index])
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func deletePost(id: Int) {
        let dataSource = (postType == .rent) ? rentDataSource : requestDataSource
        var snapshot = dataSource.snapshot()
        guard let deleteItem = snapshot.itemIdentifiers.first(where: {$0.postID == id}) else { return }
        snapshot.deleteItems([deleteItem])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func appendPost(items: [PostResponseDTO]) {
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
            if paginationFlag && scrollView.contentOffset.y > rentPostTableView.contentSize.height - 1300 {
                pagination.send(postType)
            }
        case .request:
            if paginationFlag && scrollView.contentOffset.y > requestPostTableView.contentSize.height - 1300 {
                pagination.send(postType)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        floatingButton.isActive = false
    }
    
}

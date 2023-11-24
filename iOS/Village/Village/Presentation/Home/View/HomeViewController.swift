//
//  HomeViewController.swift
//  Village
//
//  Created by 박동재 on 2023/11/15.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    
    typealias HomeDataSource = UICollectionViewDiffableDataSource<Section, PostListItem>
    typealias ViewModel = HomeViewModel
    typealias Input = ViewModel.Input
    
    private var dataSource: HomeDataSource!
    private let reuseIdentifier = HomeCollectionViewCell.identifier
    private var collectionView: UICollectionView!
    
    private var currentPage = CurrentValueSubject<Int, Never>(1)
    private var viewModel = ViewModel()

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
    
    enum Section {
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupUI()
    }
    
    private func setupUI() {
        setNavigationUI()
        setMenuUI()
        bindFloatingButton()
        configureCollectionView()
        
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
        viewModel.transform(input: Input(currentPage: currentPage))
            .postList
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] list in
                self?.configureDataSource()
                self?.generateData(postList: list)
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
        let presentPostRequestNC = UIAction(title: "대여 요청하기") { [weak self] _ in
            let postRequestVC = PostingViewController(viewModel: PostingViewModel(), type: .request)
            let postRequestNC = UINavigationController(rootViewController: postRequestVC)
            postRequestNC.modalPresentationStyle = .fullScreen
            self?.present(postRequestNC, animated: true)
        }
        let presentPostRentNC = UIAction(title: "대여 등록하기") { [weak self] _ in
            let postRentVC = PostingViewController(viewModel: PostingViewModel(), type: .rent)
            let postRentNC = UINavigationController(rootViewController: postRentVC)
            postRentNC.modalPresentationStyle = .fullScreen
            self?.present(postRentNC, animated: true)
        }
        menuView.setMenuActions([presentPostRequestNC, presentPostRentNC])
    }
    
    @objc func searchButtonTapped() {
        let nextVC = SearchViewController()
        let presentSearchNV = UINavigationController(rootViewController: nextVC)
        presentSearchNV.modalPresentationStyle = .fullScreen
        self.present(presentSearchNV, animated: true)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100.0)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10.0, leading: 0.0, bottom: 4.0, trailing: 0.0)
        section.interGroupSpacing = 8.0
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        dataSource = HomeDataSource(collectionView: collectionView) { (collectionView, indexPath, post) ->
            UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: self.reuseIdentifier,
                for: indexPath
            ) as? HomeCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configureData(post: post)
            
            if let imageURL = post.imageURL {
                let endpoint = APIEndPoints.getData(with: imageURL)
                Task {
                    do {
                        let data = try await Provider.shared.request(from: endpoint.baseURL)
                        cell.configureImage(image: UIImage(data: data))
                    } catch {
                        dump(error)
                    }
                }
            } else {
                cell.configureImage(image: nil)
            }
            
            return cell
        }
    }
    
    private func generateData(postList: [PostListItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostListItem>()
        snapshot.appendSections([.main])
        
        snapshot.appendItems(postList)
        dataSource.apply(snapshot, animatingDifferences: true)
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
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let post = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if (post.isRequest == 1) {
            let requestVC = RequestDetailViewController(postID: post.postID, userID: post.userID)
            self.navigationController?.pushViewController(requestVC, animated: true)
        } else {
            let rentVC = RentDetailViewController(postID: post.postID, userID: post.userID)
            self.navigationController?.pushViewController(rentVC, animated: true)
        }
    }
    
}
